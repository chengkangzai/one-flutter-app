class Tag {
  final String id;
  final String title;

  Tag({required this.id, required this.title});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
    );
  }
}
