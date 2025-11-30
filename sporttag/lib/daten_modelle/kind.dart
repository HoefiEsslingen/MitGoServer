class Kind {
  final int id;
  String name;
  int alter;
  DateTime updatedAt;

  Kind({
    required this.id,
    required this.name,
    required this.alter,
    required this.updatedAt,
  });

  factory Kind.fromJson(Map<String, dynamic> json) {
    return Kind(
      id: json['id'],
      name: json['name'],
      alter: json['alter'],
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'alter': alter,
        'updatedAt': updatedAt.toIso8601String(),
      };
}
