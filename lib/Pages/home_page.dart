import 'package:blink_tracker/Widgets/bottom_naviagte_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Services/forefround_service.dart';
import '../Widgets/custom_divider.dart';
import '../blink_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String text = "ON";
  int blink = 0;
  final TextEditingController _textEditingController = TextEditingController();
  int? threshold;
  bool grantedCam = true;
  final service = FlutterBackgroundService();

  @override
  void initState() {
    super.initState();
    setBlinkAndThreshold();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<BlinkProvider>(context, listen: true);
    provider.getBlinkThrehold();
    provider.getText();
  }

  setBlinkAndThreshold() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    grantedCam = await Permission.camera.isGranted;
    // text = await service.isRunning() ? 'OFF' : 'ON';

    threshold = pref.getInt('threshold') ?? 8;
    _textEditingController.text = threshold.toString();

    blink = pref.getInt('blink') ?? 0;
    setState(() {});
  }

  validateAndSave(String threshNum, BuildContext context) async {
    var thresh = int.tryParse(threshNum);
    if (thresh != null) {
      threshold = thresh;
      final provider = Provider.of<BlinkProvider>(context, listen: false);

      provider.setBlinkThreshold(threshold!);

      naigatorPop(context);

      var isRunning = await service.isRunning();
      if (isRunning) {
        showSnackBar('Stop tracking to apply changes', false);
      }
    }
  }

  showSnackBar(String message, bool isCAM) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        action: isCAM
            ? null
            : SnackBarAction(
                label: 'STOP',
                textColor: Colors.red[200],
                onPressed: () async {
                  var isRunning = await service.isRunning();
                  if (isRunning) {
                    service.invoke("stopService");
                  }
                  service.startService();

                  BlinkProvider bp = BlinkProvider();
                  bp.getText();
                },
              ),
      ),
    );
  }

  naigatorPop(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setInt('blink', blink);
    }
  }

  @override
  Widget build(BuildContext context) {
    final blinkProvider = Provider.of<BlinkProvider>(context, listen: true);
    text = blinkProvider.text;
    return Scaffold(
      bottomNavigationBar: const BottomNavigator(),
      backgroundColor: const Color.fromARGB(255, 31, 31, 30),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 31, 31, 30),
        title: const Text(
          'Blink Tracker',
          style: TextStyle(color: Color.fromARGB(255, 253, 253, 253)),
        ),
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
          stream: FlutterBackgroundService().on('update'),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              blink = snapshot.data!['blink'] ?? 0;
            }
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: grantedCam
                          ? () async {
                              final service = FlutterBackgroundService();
                              var isRunning = await service.isRunning();
                              if (isRunning) {
                                service.invoke("stopService");
                              } else {
                                await service.startService();
                              }

                              blinkProvider.getText();
                              // Button pressed logic
                            }
                          : () async {
                              showSnackBar(
                                  'Please grant camera permission', true);
                              if (await Permission.camera.request().isGranted) {
                                await initializeService();
                                setState(() {
                                  grantedCam = true;
                                });
                              }
                            },
                      style: grantedCam
                          ? ElevatedButton.styleFrom(
                              shadowColor: text == 'OFF'
                                  ? const Color.fromARGB(255, 253, 106, 96)
                                  : const Color.fromARGB(255, 105, 185, 112),
                              backgroundColor:
                                  const Color.fromARGB(255, 31, 31, 30),
                              padding: const EdgeInsets.all(70),
                              shape: CircleBorder(
                                  side: BorderSide(
                                      color: text == 'OFF'
                                          ? const Color.fromARGB(
                                              255, 253, 106, 96)
                                          : const Color.fromARGB(
                                              255, 105, 185, 112))),
                            )
                          : ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(70),
                              backgroundColor:
                                  const Color.fromARGB(255, 31, 31, 30),
                              shape: const CircleBorder(
                                  side: BorderSide(color: Colors.grey)),
                            ),
                      child: grantedCam
                          ? Text(
                              text,
                              style: TextStyle(
                                  fontSize: 30,
                                  color: text == 'OFF'
                                      ? const Color.fromARGB(255, 253, 106, 96)
                                      : const Color.fromARGB(
                                          255, 105, 185, 112)),
                            )
                          : const Text(
                              'Grant Camera \n Permission',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 20),
                            ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    if (grantedCam)
                      Text(
                        text == "OFF"
                            ? "Blink Tracking has Started"
                            : "Click on 'ON' button to start tracking",
                        style: const TextStyle(
                            color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 30, top: 60, bottom: 10),
                      child: Row(children: const [
                        Text(
                          textAlign: TextAlign.start,
                          'Settings',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 253, 253, 253),
                          ),
                        ),
                      ]),
                    ),
                    CustomDivider(thickness: 3),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 10),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 16, 16, 15),
                            minimumSize: const Size.fromHeight(50),
                          ),
                          onPressed: () {},
                          child: Row(
                            children: [
                              const Text(
                                'Blink Count ',
                                style: TextStyle(color: Colors.white),
                              ),
                              const Spacer(),
                              Text(
                                blink.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 16, 16, 15),
                            minimumSize: const Size.fromHeight(50),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => Builder(builder: (context) {
                                return AlertDialog(
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            validateAndSave(
                                                _textEditingController.text,
                                                context);
                                          },
                                          child: const Text(
                                            'Save',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Cancel',
                                              style: TextStyle(
                                                  color: Colors.white))),
                                    ],
                                    backgroundColor:
                                        const Color.fromARGB(255, 31, 31, 30),
                                    surfaceTintColor:
                                        const Color.fromARGB(255, 31, 31, 30),
                                    content: Container(
                                      color:
                                          const Color.fromARGB(255, 31, 31, 30),
                                      child: TextField(
                                        cursorColor: Colors.white,
                                        onSubmitted: (threshold) {
                                          validateAndSave(threshold, context);
                                        },
                                        style: const TextStyle(
                                            color: Colors.white),
                                        controller: _textEditingController,
                                        keyboardType: TextInputType.phone,
                                      ),
                                    ));
                              }),
                            );
                          },
                          child: Row(
                            children: [
                              const Text(
                                'Current Threshold ',
                                style: TextStyle(color: Colors.white),
                              ),
                              const Spacer(),
                              Text(
                                blinkProvider.blinkThreshold.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          )),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
