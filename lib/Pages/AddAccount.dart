import 'package:autonetwork/Pages/user_prefs.dart';
import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

import '../backend_services/backend_services.dart';
import '../DTO/CustomerDTO.dart';
import '../DTO/CarRepairLogRequestDTO.dart';
import '../DTO/CarRepairLogResponseDTO.dart';
import '../DTO/permissions.dart';
import '../DTO/roles.dart';
import 'Components/CarRepairedLogCard.dart';
import 'Components/CarRepairLogListView.dart';
import 'CustomerInfoCard.dart';
import 'Components/helpers/app_helpers.dart';

class AddAccount extends StatefulWidget {
  const AddAccount({Key? key}) : super(key: key);

  @override
  State<AddAccount> createState() => _AddAccountState();
}

class _AddAccountState extends State<AddAccount> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  String? _selectedRole;
  String? _selectedPermission;

  List<String> rolesName = [];
  List<String> permissionsName = [];

  List<permissions> _permissionsList = [];
  List<roles> _rolesList = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final permissionsResponse = await backend_services().fetchAllPermissions();
    final rolesResponse = await backend_services().fetchAllRoles();

    if (!mounted) return;

    setState(() {
      _permissionsList = permissionsResponse.data ?? [];
      _rolesList = rolesResponse.data ?? [];

      permissionsName = _permissionsList.map((p) => p.permissionName).toList();
      rolesName = _rolesList.map((r) => r.roleName).toList();
    });
  }


  Future<void> saveNewUser() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;

    roles? foundRole = _rolesList.firstWhere(
          (p) => p.roleName == _selectedRole,
      orElse: () => roles(id: "null", roleName: "NotFound"),
    );

    permissions? foundPermission = _permissionsList.firstWhere(
          (p) => p.permissionName == _selectedPermission,
      orElse: () => permissions(id: "null", permissionName: "NotFound"),
    );


    final response = await backend_services().registerUser(
      username: username,
      password: password,
      firstName: firstName,
      lastName: lastName,
      roleId: foundRole.id,
      roleName: foundRole.roleName,
      permissionId: foundPermission.id,
      permissionName: foundPermission.permissionName,
    );
    if (response.status == 'success') {
      StringHelper.showInfoDialog(context, "${response.message}");
    } else {
      StringHelper.showErrorDialog(context, "${response.message}");
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Yeni Personel Bilgileri",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'Kullanıcı Adı',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen kullanıcı adını girin';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Şifre',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen şifreyi girin';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: _firstNameController,
          decoration: const InputDecoration(
            labelText: 'Adı',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen adı girin';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: _lastNameController,
          decoration: const InputDecoration(
            labelText: 'Soyadı',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen soyadı girin';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          items: rolesName.map((role) {
            return DropdownMenuItem<String>(
              value: role,
              child: Text(role),
            );
          }).toList(),
          decoration: const InputDecoration(
            labelText: 'Rol Seçin',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _selectedRole = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Lütfen bir rol seçin';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        DropdownButtonFormField<String>(
          value: _selectedPermission,
          items: permissionsName.map((perm) {
            return DropdownMenuItem<String>(
              value: perm,
              child: Text(perm),
            );
          }).toList(),
          decoration: const InputDecoration(
            labelText: 'Yetki Seviyesi',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _selectedPermission = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Lütfen yetki seviyesi seçin';
            }
            return null;
          },
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await saveNewUser();
                }
              },
              child: const Text('Onayla'),
            ),
          ],
        )
      ],
    );
  }
}
