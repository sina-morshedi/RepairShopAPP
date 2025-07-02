import 'package:flutter/widgets.dart';

class Profile {
  final ImageProvider photo;
  final String first_name;
  final String last_name;
  final String role_name;

  const Profile({
    required this.photo,
    required this.first_name,
    required this.last_name,
    required this.role_name,
  });
}
