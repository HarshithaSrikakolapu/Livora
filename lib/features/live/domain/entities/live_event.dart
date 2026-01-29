class LiveEvent {
  final String organizationId;
  final String platform; // 'youtube' or 'facebook'
  final String url;
  final DateTime startedAt;

  LiveEvent({
    required this.organizationId,
    required this.platform,
    required this.url,
    required this.startedAt,
  });
}
