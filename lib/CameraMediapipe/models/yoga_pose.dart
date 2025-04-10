class YogaPose {
  final String id;
  final String name;
  final int timeup;
  final String video;

  YogaPose({
    required this.id,
    required this.name,
    required this.timeup,
    required this.video,
  });

  factory YogaPose.fromMap(Map<String, dynamic> map, String id) {
    return YogaPose(
      id: id,
      name: map['Name'] ?? '',
      timeup: map['Timeup'] ?? 30,
      video: map['Video'] ?? 'rest_video.mp4',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "timeup": timeup,
      "video": video,
    };
  }
}
