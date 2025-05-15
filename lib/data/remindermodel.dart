class ReminderModel {
  final int id;
  final String name;
  final int hour;
  final int minute;

  ReminderModel({
    required this.id,
    required this.name,
    required this.hour,
    required this.minute,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'hour': hour,
    'minute': minute,
  };

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'],
      name: map['name'],
      hour: map['hour'],
      minute: map['minute'],
    );
  }
}
