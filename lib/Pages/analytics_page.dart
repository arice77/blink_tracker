import 'package:blink_tracker/Model/blink_model.dart';
import 'package:blink_tracker/Services/db_service.dart';
import 'package:blink_tracker/Widgets/bottom_naviagte_bar.dart';
import 'package:blink_tracker/Widgets/custom_divider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<BlinkModel> listOfBlinkCounts = [];
  List<BarChartGroupData> listOfBars = [];
  List<BlinkModelTime> listOfHourlyBlinkCounts = [];
  List<BarChartGroupData> listOfBarHour = [];
  bool isMinuteView = true;
  bool isLoading = true;
  double avgBlink = 0.0;
  bool something = true;
  int selectedIndex = 0;
  List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    initialize();
  }

  n(String time) {
    String currentTime = listOfBlinkCounts[0].id;
    int i = 0;
    listOfHourlyBlinkCounts = [];

    switch (time) {
      case 'hour':
        {
          while (something) {
            double sum = 0;
            int j = 0;
            while (DateTime.parse(currentTime).year ==
                    DateTime.parse(listOfBlinkCounts[i].id).year &&
                DateTime.parse(currentTime).month ==
                    DateTime.parse(listOfBlinkCounts[i].id).month &&
                DateTime.parse(currentTime).day ==
                    DateTime.parse(listOfBlinkCounts[i].id).day &&
                DateTime.parse(currentTime).hour ==
                    DateTime.parse(listOfBlinkCounts[i].id).hour) {
              sum += listOfBlinkCounts[i].blinkCount;
              j++;
              i++;
              if (i == listOfBlinkCounts.length) {
                break;
              }
            }
            sum /= j;
            j = 0;
            listOfHourlyBlinkCounts.add(BlinkModelTime(
              blinkCount: double.tryParse(sum.toStringAsFixed(2)) ?? 0.0,
              timeOfBlink: '${DateTime.parse(currentTime).hour.toString()}:00',
            ));
            if (i == listOfBlinkCounts.length) {
              break;
            }
            currentTime = listOfBlinkCounts[i].id;
          }
          break;
        }

      case 'day':
        {
          while (something) {
            double sum = 0;
            int j = 0;
            while (DateTime.parse(currentTime).year ==
                    DateTime.parse(listOfBlinkCounts[i].id).year &&
                DateTime.parse(currentTime).month ==
                    DateTime.parse(listOfBlinkCounts[i].id).month &&
                DateTime.parse(currentTime).day ==
                    DateTime.parse(listOfBlinkCounts[i].id).day) {
              sum += listOfBlinkCounts[i].blinkCount;
              j++;
              i++;
              if (i == listOfBlinkCounts.length) {
                break;
              }
            }
            sum /= j;
            j = 0;
            listOfHourlyBlinkCounts.add(BlinkModelTime(
              blinkCount: double.tryParse(sum.toStringAsFixed(2)) ?? 0.0,
              timeOfBlink:
                  '${DateTime.parse(currentTime).day} ${months[DateTime.parse(currentTime).month - 1]}',
            ));
            if (i == listOfBlinkCounts.length) {
              break;
            }
            currentTime = listOfBlinkCounts[i].id;
          }
        }
        break;

      case 'month':
        {
          while (something) {
            double sum = 0;
            int j = 0;
            while (DateTime.parse(currentTime).year ==
                    DateTime.parse(listOfBlinkCounts[i].id).year &&
                DateTime.parse(currentTime).month ==
                    DateTime.parse(listOfBlinkCounts[i].id).month) {
              sum += listOfBlinkCounts[i].blinkCount;
              j++;
              i++;
              if (i == listOfBlinkCounts.length) {
                break;
              }
            }
            sum /= j;
            j = 0;
            listOfHourlyBlinkCounts.add(BlinkModelTime(
              blinkCount: double.tryParse(sum.toStringAsFixed(2)) ?? 0.0,
              timeOfBlink: months[DateTime.parse(currentTime).month],
            ));
            if (i == listOfBlinkCounts.length) {
              break;
            }
            currentTime = listOfBlinkCounts[i].id;
          }
          break;
        }
      case 'year':
        {
          while (something) {
            double sum = 0;
            int j = 0;
            while (DateTime.parse(currentTime).year ==
                DateTime.parse(listOfBlinkCounts[i].id).year) {
              sum += listOfBlinkCounts[i].blinkCount;
              j++;
              i++;
              if (i == listOfBlinkCounts.length) {
                break;
              }
            }
            sum /= j;
            j = 0;
            listOfHourlyBlinkCounts.add(BlinkModelTime(
              blinkCount: double.tryParse(sum.toStringAsFixed(2)) ?? 0.0,
              timeOfBlink: DateTime.parse(currentTime).year.toString(),
            ));
            if (i == listOfBlinkCounts.length) {
              break;
            }
            currentTime = listOfBlinkCounts[i].id;
          }
        }
        break;
    }
    listOfBarHour = [];

    for (BlinkModelTime item in listOfHourlyBlinkCounts) {
      listOfBarHour.add(
        BarChartGroupData(x: 2, barRods: [
          BarChartRodData(
            toY: item.blinkCount.toDouble(),
            width: 35,
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
        ]),
      );
    }
  }

  double findAvergaeBlink() {
    int index = 0;
    int sum = 0;
    if (listOfBlinkCounts.isEmpty) {
      return 0.00;
    }
    while (
        DateTime.parse(listOfBlinkCounts[index].id).day == DateTime.now().day &&
            DateTime.parse(listOfBlinkCounts[index].id).month ==
                DateTime.now().month &&
            DateTime.parse(listOfBlinkCounts[index].id).year ==
                DateTime.now().year) {
      sum += listOfBlinkCounts[index].blinkCount;

      index++;
      if (index == listOfBlinkCounts.length) {
        break;
      }
    }
    return sum / index;
  }

  initialize() async {
    List<Map<String, Object?>> list = await DBHelper.getBlink('blinks');
    list = list.reversed.toList();
    for (Map<String, Object?> item in list) {
      listOfBlinkCounts.add(BlinkModel(
          id: item['id'] as String,
          blinkCount: item['blinkCount'] as int,
          timeOfBlinkCount: item['time'] as String));
    }

    for (BlinkModel item in listOfBlinkCounts) {
      listOfBars.add(
        BarChartGroupData(x: 2, barRods: [
          BarChartRodData(
            toY: item.blinkCount.toDouble(),
            width: 35,
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
        ]),
      );
    }
    avgBlink = findAvergaeBlink();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 31, 31, 30),
      bottomNavigationBar: const BottomNavigator(),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 31, 31, 30),
        title: const Text(
          'Analytics',
          style: TextStyle(
            color: Color.fromARGB(255, 253, 253, 253),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: const [
                        SizedBox(
                          width: 22,
                        ),
                        Text(
                          'Today',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                    CustomDivider(thickness: 1),
                    const SizedBox(height: 20),
                    const Text(
                      'Average blink rate :',
                      style: TextStyle(
                          color: Color.fromARGB(255, 253, 253, 253),
                          fontSize: 18),
                    ),
                    Text(
                      avgBlink.toStringAsFixed(2),
                      style: const TextStyle(
                          color: Color.fromARGB(255, 253, 253, 253),
                          fontSize: 45,
                          fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      ' per minute',
                      style: TextStyle(
                          color: Color.fromARGB(255, 253, 253, 253),
                          fontSize: 18),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: const [
                        SizedBox(
                          width: 22,
                        ),
                        Text(
                          'Statistics',
                          style: TextStyle(
                              color: Color.fromARGB(255, 253, 253, 253),
                              fontSize: 18),
                        ),
                      ],
                    ),
                    CustomDivider(thickness: 1),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        DropdownButton(
                            iconEnabledColor: Colors.white,
                            menuMaxHeight: 200,
                            hint: const Text(
                              'View',
                              style: TextStyle(color: Colors.white),
                            ),
                            focusColor: Colors.white,
                            items: const [
                              DropdownMenuItem(
                                value: 'Min',
                                child: Text('Minute Wise'),
                              ),
                              DropdownMenuItem(
                                value: 'hour',
                                child: Text('Avg Hourly'),
                              ),
                              DropdownMenuItem(
                                  value: 'day', child: Text('Avg Daily')),
                              DropdownMenuItem(
                                  value: 'month', child: Text('Avg Monthly')),
                              DropdownMenuItem(
                                  value: 'year', child: Text('Avg Yearly'))
                            ],
                            onChanged: (v) {
                              if (v == 'Min') {
                                isMinuteView = true;
                                setState(() {});
                                return;
                              }
                              isMinuteView = false;
                              n(v.toString());
                              setState(() {});
                            }),
                        const SizedBox(
                          width: 20,
                        )
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(10)),
                      child: listOfBlinkCounts.isEmpty
                          ? const Center(
                              child: Text(
                              'No recorded blinks',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 253, 253, 253),
                                  fontSize: 16),
                            ))
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                height: 250,
                                width: 45 *
                                    (isMinuteView
                                        ? listOfBars.length.toDouble()
                                        : listOfBarHour.length.toDouble()),
                                child: AnalyticsBar(
                                  list: listOfBars,
                                  listBlinks: listOfBlinkCounts,
                                  isMinuteView: isMinuteView,
                                  listBarHour: listOfBarHour,
                                  listHour: listOfHourlyBlinkCounts,
                                  i2: 0,
                                  i: 0,
                                  j: 0,
                                  j2: 0,
                                ),
                              )),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class AnalyticsBar extends StatefulWidget {
  List<BlinkModel> listBlinks;
  List<BarChartGroupData> list;
  List<BlinkModelTime> listHour;
  List<BarChartGroupData> listBarHour;
  bool isMinuteView;
  int i;
  int j;
  int i2;
  int j2;
  AnalyticsBar(
      {super.key,
      required this.list,
      required this.listBlinks,
      required this.isMinuteView,
      required this.listBarHour,
      required this.listHour,
      required this.i,
      required this.i2,
      required this.j,
      required this.j2});

  @override
  State<AnalyticsBar> createState() => _AnalyticsBarState();
}

class _AnalyticsBarState extends State<AnalyticsBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: BarChart(BarChartData(
          alignment: BarChartAlignment.spaceAround,
          titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (widget.isMinuteView) {
                    if (widget.i == widget.listBlinks.length) widget.i = 0;
                    return Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Text(
                        widget.listBlinks[widget.i++].timeOfBlinkCount,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    );
                  } else {
                    if (widget.i2 == widget.listHour.length) widget.i2 = 0;
                    return Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Text(
                        widget.listHour[widget.i2++].timeOfBlink,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    );
                  }
                },
              )),
              topTitles: AxisTitles(
                  sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (widget.isMinuteView) {
                    if (widget.j == widget.listBlinks.length) widget.j = 0;
                    return Text(
                      widget.listBlinks[widget.j++].blinkCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    );
                  } else {
                    if (widget.j2 == widget.listHour.length) widget.j2 = 0;
                    return Text(
                      widget.listHour[widget.j2++].blinkCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    );
                  }
                },
              )),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false))),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(
              border: const Border(
            top: BorderSide.none,
            right: BorderSide.none,
            left: BorderSide.none,
            bottom: BorderSide.none,
          )),
          groupsSpace: 2,

          // add bars
          barGroups: widget.isMinuteView ? widget.list : widget.listBarHour)),
    );
  }
}
