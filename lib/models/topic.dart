
class Topic  {
  final String topicName;
  final String icon;
  final  String id;

  Topic({
    required this.topicName,
    required this.icon,
    required this.id,
  });

  // Convert Marriage object to a Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'topicName': topicName,
      'icon': icon,
      'id': id,
    };
  }

  // Factory method to create Marriage object from Firebase data
  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      topicName: map['topicName'],
      icon: map['icon'],
      id: map['id'],
    );
  }
}
