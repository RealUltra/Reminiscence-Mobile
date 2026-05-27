class ParticipantDetailsData {
  final String name;
  final int messageCount;

  const ParticipantDetailsData({
    required this.name,
    required this.messageCount,
  });

  factory ParticipantDetailsData.fromTimestamps({
    required String name,
    required List<int> timestamps,
  }) {
    return ParticipantDetailsData(name: name, messageCount: timestamps.length);
  }
}
