class ApiEndpoints {
  static const String _baseUrl = "https://fastapi-java-backend-production.up.railway.app";

  static const String login = "$_baseUrl/users/login";
  static const String register = "$_baseUrl/register";
  static const String getProfile = "$_baseUrl/user/profile";
  static const String getAllProfile = "$_baseUrl/users/all";
  static const String countAllMembers = "$_baseUrl/users/count";
  static const String getAllRoles = "$_baseUrl/roles/all";
  static const String getAllPermissions = "$_baseUrl/permissions/all";
  static const String registerUser = "$_baseUrl/auth/register";
}


class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}
