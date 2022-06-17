class AuthenticationData {
  String? accessToken;
  String? refreshToken;
  String? error;
  int? expiresIn;

  AuthenticationData({
    this.accessToken,
    this.refreshToken,
    this.error,
    this.expiresIn,
  });

  factory AuthenticationData.fromJson(Map<String, dynamic> json) {
    return AuthenticationData(
      accessToken: json['access_token'] == null ? null : json['access_token'],
      refreshToken:  json['refreshToken'] == null ? null : json['refreshToken'],
      error: json['error'] == null ? null : json['error'],
      expiresIn: json['expiresIn'] == null ? null : json['expiresIn']
    );
  }

  bool hasError() {
    return error != null;
  }
}
