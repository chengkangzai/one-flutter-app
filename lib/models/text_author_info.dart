class TextAuthorInfo {
  final String textAuthorName;
  final String textAuthorWork;
  final String textAuthorDesc;

  TextAuthorInfo({
    required this.textAuthorName,
    required this.textAuthorWork,
    required this.textAuthorDesc,
  });

  factory TextAuthorInfo.fromJson(Map<String, dynamic> json) {
    return TextAuthorInfo(
      textAuthorName: json['text_author_name'] ?? '',
      textAuthorWork: json['text_author_work'] ?? '',
      textAuthorDesc: json['text_author_desc'] ?? '',
    );
  }
}