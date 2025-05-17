class Progress {
  final double value;
  final String? label;

  Progress({required this.value, this.label});

  Map<String, dynamic> toMap() {
    return {"value": value, "label": label};
  }

  factory Progress.fromMap(Map<String, dynamic> map) {
    return Progress(value: map["value"], label: map["label"]);
  }
}
