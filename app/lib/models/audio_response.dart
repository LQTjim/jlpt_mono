class AudioResponse {
  final String status;
  final int? jobId;
  final String? presignedUrl;
  final DateTime? expiresAt;
  final String? errorMessage;

  const AudioResponse({
    required this.status,
    this.jobId,
    this.presignedUrl,
    this.expiresAt,
    this.errorMessage,
  });

  factory AudioResponse.fromJson(Map<String, dynamic> json) {
    return AudioResponse(
      status: json['status'] as String,
      jobId: (json['jobId'] as num?)?.toInt(),
      presignedUrl: json['presignedUrl'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String).toUtc()
          : null,
      errorMessage: json['errorMessage'] as String?,
    );
  }
}
