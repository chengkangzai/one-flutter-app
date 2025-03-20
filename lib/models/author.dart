class Author {
  final String userId;
  final String userName;
  final String desc;
  final String wbName;
  final String isSettled;
  final String settledType;
  final String summary;
  final String fansTotal;
  final String webUrl;

  Author({
    required this.userId,
    required this.userName,
    required this.desc,
    required this.wbName,
    required this.isSettled,
    required this.settledType,
    required this.summary,
    required this.fansTotal,
    required this.webUrl,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      // Convert all fields to strings
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name'] ?? '',
      desc: json['desc'] ?? '',
      wbName: json['wb_name'] ?? '',
      isSettled: json['is_settled']?.toString() ?? '',
      settledType: json['settled_type']?.toString() ?? '',
      summary: json['summary'] ?? '',
      fansTotal: json['fans_total']?.toString() ?? '',
      webUrl: json['web_url'] ?? '',
    );
  }
}