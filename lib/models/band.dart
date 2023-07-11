class Band {
  String? id;
  String? name;
  int? votes;

  Band({this.id, this.name, this.votes});

  factory Band.fromMap(Map<String, dynamic> json) => Band(
      id: json["id"] ?? "null",
      name: json["name"] ?? "no title",
      votes: json["votes"] ?? 0);
}
