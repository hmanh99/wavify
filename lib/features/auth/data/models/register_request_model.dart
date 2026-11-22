class RegisterRequestModel {
  final String fullName;
  final String email;
  final String password;
  final String? username;

  const RegisterRequestModel({
    required this.fullName,
    required this.email,
    required this.password,
    this.username,
  });

  Map<String, dynamic> toJson() {
    // Generate valid username (at least 4 chars, no spaces) if not explicitly provided
    String resolvedUsername = (username ?? fullName).trim().replaceAll(RegExp(r'\s+'), '');
    if (resolvedUsername.length < 4) {
      final emailPrefix = email.contains('@') ? email.split('@').first : 'user';
      resolvedUsername = (resolvedUsername + emailPrefix).replaceAll(RegExp(r'\s+'), '');
      if (resolvedUsername.length < 4) {
        resolvedUsername = 'user_${DateTime.now().millisecondsSinceEpoch % 10000}';
      }
    }

    return {
      'username': resolvedUsername,
      'fullName': fullName,
      'name': fullName,
      'email': email,
      'password': password,
    };
  }
}
