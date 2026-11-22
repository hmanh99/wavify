class UpdateUserRequestModel {
  final String? username;
  final String? email;
  final String? password;

  const UpdateUserRequestModel({
    this.username,
    this.email,
    this.password,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (username != null && username!.trim().isNotEmpty) {
      map['username'] = username!.trim();
    }
    if (email != null && email!.trim().isNotEmpty) {
      map['email'] = email!.trim();
    }
    if (password != null && password!.trim().isNotEmpty) {
      map['password'] = password!.trim();
    }
    return map;
  }
}

