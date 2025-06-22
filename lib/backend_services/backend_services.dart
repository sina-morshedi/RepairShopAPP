import 'package:flutter/material.dart';

import 'package:autonetwork/models/users.dart';
import 'package:autonetwork/models/roles.dart';
import 'package:autonetwork/models/permissions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ApiEndpoints.dart';

class backend_services {
  Future<List<users>> fetchAllProfile({BuildContext? context}) async {
    final String backendUrl = ApiEndpoints.getAllProfile;

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          return data.map((e) => users.fromJson(e)).toList();
        } else if (data is Map<String, dynamic>) {
          return [users.fromJson(data)];
        } else {
          //TODO Return the appropriate error.
          return [];
        }
      } else {
        final data = jsonDecode(response.body);
        String error = data['error'] ?? 'Fetch failed';
        //TODO Return the appropriate error.
        return [];
      }
    } catch (e) {
      //TODO Return the appropriate error.
      return [];
    }
  }

  Future<List<permissions>> fetchAllPermissions({BuildContext? context}) async {
    final String backendUrl = ApiEndpoints.getAllPermissions;

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          return data.map((e) => permissions.fromJson(e)).toList();
        } else if (data is Map<String, dynamic>) {
          return [permissions.fromJson(data)];
        } else {
          //TODO Return the appropriate error.
          return [];
        }
      } else {
        final data = jsonDecode(response.body);
        String error = data['error'] ?? 'Fetch failed';
        //TODO Return the appropriate error.
        return [];
      }
    } catch (e) {
      //TODO Return the appropriate error.
      return [];
    }
  }

  Future<List<roles>> fetchAllRoles({BuildContext? context}) async {
    final String backendUrl = ApiEndpoints.getAllRoles;

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          return data.map((e) => roles.fromJson(e)).toList();
        } else if (data is Map<String, dynamic>) {
          return [roles.fromJson(data)];
        } else {
          //TODO Return the appropriate error.
          return [];
        }
      } else {
        final data = jsonDecode(response.body);
        String error = data['error'] ?? 'Fetch failed';
        //TODO Return the appropriate error.
        return [];
      }
    } catch (e) {
      //TODO Return the appropriate error.
      return [];
    }
  }

  Future<int> countAllMembers({BuildContext? context}) async {
    final String backendUrl = ApiEndpoints.countAllMembers;

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['count'] != null) {
          return data['count'] as int;
        } else {
          return -1;
        }
      } else {
        return -1;
      }
    } catch (e) {
      return -1;
    }
  }


  Future<String> registerUser({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String roleId,
    required String permissionId,
  }) async {
    final String backendUrl = ApiEndpoints.registerUser;  // مثلا "https://.../auth/register"

    final Map<String, dynamic> requestBody = {
      "username": username,
      "password": password,
      "firstName": firstName,
      "lastName": lastName,
      "roleId": roleId,
      "permissionId": permissionId,
    };

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );
      return response.body;

    } catch (e) {
      print("Error in registerUser: $e");
      return "Error in registerUser: $e";
    }
  }
}