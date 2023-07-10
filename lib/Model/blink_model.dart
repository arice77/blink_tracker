class BlinkModel {
  String id;
  int blinkCount;
  String timeOfBlinkCount;
  BlinkModel(
      {required this.id,
      required this.blinkCount,
      required this.timeOfBlinkCount});
}

class BlinkModelTime {
  double blinkCount;
  String timeOfBlink;
  BlinkModelTime({required this.blinkCount, required this.timeOfBlink});
}
