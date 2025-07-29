import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

import '../backend_services/backend_services.dart';

import 'Components/helpers/app_helpers.dart';
import 'Customer_Add.dart';
import 'Customer_Editor.dart';

import '../DTO/TaskStatusDTO.dart';
import '../DTO/UserProfileDTO.dart';
import '../DTO/RolesDTO.dart';
import '../DTO/roles.dart';
import '../DTO/permissions.dart';
import '../DTO/UpdateUserDTO.dart';
import 'AddAccount.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  String selectedSetting = 'Kullanıcılar ekle';
  final List<String> settingOptions = [
    'Kullanıcılar ekle',
    'Kullanıcılar düzenle',
    'Müşteri bilgilerini ekle',
    'Müşteri bilgilerini düzenle',
  ];
  final UserApi userApi = UserApi();

  bool isAddingNew = false;
  final TextEditingController newEntryController = TextEditingController();

  List<TaskStatusDTO> taskStatusList = [];
  List<RolesDTO> rolesList = [];
  List<UserProfileDTO> usersList = [];

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _isEditingMap = {};

  @override
  void initState() {
    super.initState();
    _handleSettingChange(selectedSetting);
  }

  @override
  void dispose() {
    newEntryController.dispose();
    _controllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  void _handleSettingChange(String setting) {
    setState(() {
      selectedSetting = setting;
      isAddingNew = false;
      newEntryController.clear();
    });

    if (setting == 'Görev Durumu') {
      fetchTaskStatuses();
    } else if (setting == 'Roller') {
      fetchRoles();
    } else if (setting == 'Kullanıcılar düzenle') {
      fetchUsers();
    }
  }

  void fetchUsers() async {
    final response = await UserApi().getAllUsers();
    if (!mounted) return; // ✅ اضافه شود

    if (response.status == 'success' && response.data != null) {
      setState(() {
        usersList = response.data!;
      });
    } else {
      StringHelper.showErrorDialog(
          context, "Failed to fetch users: ${response.message}");
    }
  }

  void fetchRoles() async {
    final response = await RoleApi().getAllRoles();
    if (!mounted) return; // ✅ اضافه شود

    if (response.status == 'success' && response.data != null) {
      setState(() {
        rolesList = response.data!;
        for (var item in rolesList) {
          if (!_controllers.containsKey(item.id ?? '')) {
            _controllers[item.id ?? ''] =
                TextEditingController(text: item.roleName);
            _isEditingMap[item.id ?? ''] = false;
          }
        }
      });
    } else {
      StringHelper.showErrorDialog(
          context, "Failed to fetch roles: ${response.message}");
    }
  }

  void fetchTaskStatuses() async {
    final response = await TaskStatusApi().getAllStatuses();
    if (!mounted) return; // ✅ اضافه شود

    if (response.status == 'success' && response.data != null) {
      setState(() {
        taskStatusList = response.data!;
        for (var item in taskStatusList) {
          if (!_controllers.containsKey(item.id ?? '')) {
            _controllers[item.id ?? ''] =
                TextEditingController(text: item.taskStatusName);
            _isEditingMap[item.id ?? ''] = false;
          }
        }
      });
    } else {
      StringHelper.showErrorDialog(
          context, "Görev durumları alınamadı: ${response.message}");
    }
  }

  void sendToBackend(String id, String newValue) async {
    final updated = TaskStatusDTO(id: id, taskStatusName: newValue.trim());
    final response = await TaskStatusApi().updateStatus(updated);
    if (response.status == 'success') {
      fetchTaskStatuses();
    } else {
      StringHelper.showErrorDialog(context, "${response.message}");
    }
  }

  void updateRole(String id, String newValue) async {
    final updated = RolesDTO(id: id, roleName: newValue.trim());
    final response = await RoleApi().updateRole(updated);
    if (response.status == 'success') {
      fetchRoles();
    } else {
      StringHelper.showErrorDialog(
          context, "Update failed: ${response.message}");
    }
  }

  void deleteTaskStatus(String id) async {
    final response = await TaskStatusApi().deleteStatus(id);
    if (response.status == 'success') {
      setState(() {
        taskStatusList.removeWhere((element) => element.id == id);
        _controllers.remove(id)?.dispose();
        _isEditingMap.remove(id);
      });
    } else {
      StringHelper.showErrorDialog(
          context, "Delete failed: ${response.message}");
    }
  }

  void deleteRole(String id) async {
    final response = await RoleApi().deleteRole(id);
    if (response.status == 'success') {
      setState(() {
        rolesList.removeWhere((element) => element.id == id);
        _controllers.remove(id)?.dispose();
        _isEditingMap.remove(id);
      });
    } else {
      StringHelper.showErrorDialog(
          context, "Delete failed: ${response.message}");
    }
  }

  void sendToBackendInsert(String value) async {
    if (selectedSetting == 'Görev Durumu') {
      final status = TaskStatusDTO(taskStatusName: value);
      final response = await TaskStatusApi().insertStatus(status);
      if (!mounted) return; // ✅ اضافه شود
      if (response.status == 'success') {
        fetchTaskStatuses();
      } else {
        StringHelper.showErrorDialog(context, "Hata: ${response.message}");
      }
    } else if (selectedSetting == 'Roller') {
      final role = RolesDTO(roleName: value);
      final response = await RoleApi().insertRole(role);
      if (!mounted) return; // ✅ اضافه شود
      if (response.status == 'success') {
        fetchRoles();
      } else {
        StringHelper.showErrorDialog(context, "Hata: ${response.message}");
      }
    }

    if (!mounted) return; // ✅ اضافه شود
    setState(() {
      isAddingNew = false;
      newEntryController.clear();
    });
  }

  Future<void> _confirmDeleteUser(UserProfileDTO user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Silmek istediğinize emin misiniz?'),
        content:
            Text('Kullanıcı ${user.username} silinecek. Onaylıyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hayır'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Evet'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await userApi.deleteUser(user.userId);
      if (response.status == 'success') {
        StringHelper.showInfoDialog(context, "${response.message}");
        fetchUsers();
      } else {
        StringHelper.showErrorDialog(
            context, "Silme hatası: ${response.message}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand( // ⬅ این خط خیلی مهمه
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ayarlar", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedSetting,
              items: settingOptions.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _handleSettingChange(newValue);
                }
              },
              decoration: const InputDecoration(
                labelText: "Setting",
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 24),

            if (isAddingNew)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextFormField(
                  controller: newEntryController,
                  decoration: InputDecoration(
                    labelText: "Enter new $selectedSetting",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(EvaIcons.checkmarkCircle2Outline),
                      onPressed: () {
                        final value = newEntryController.text.trim();
                        if (value.isNotEmpty) {
                          sendToBackendInsert(value);
                        }
                      },
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (selectedSetting == 'Kullanıcılar ekle') AddAccount(),
            if (selectedSetting == 'Kullanıcılar düzenle') _buildUsersList(),
            if (selectedSetting == 'Müşteri bilgilerini ekle') CustomerAdd(),
            if (selectedSetting == 'Müşteri bilgilerini düzenle') CustomerEditor(),
          ],
        ),
      ),
    );
  }




  Widget _buildEditableItem({
    required String id,
    required String initialText,
    required Function(String) onSave,
    required VoidCallback onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controllers[id],
              readOnly: !_isEditingMap[id]!,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: _isEditingMap[id]! ? Colors.white : Colors.grey[200],
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onSubmitted: (value) {
                if (value.trim().isEmpty || value == initialText) {
                  setState(() {
                    _isEditingMap[id] = false;
                  });
                  return;
                }
                onSave(value);
                setState(() {
                  _isEditingMap[id] = false;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              _isEditingMap[id]!
                  ? EvaIcons.checkmarkCircle2Outline
                  : EvaIcons.edit2Outline,
              color: Colors.blue,
            ),
            onPressed: () {
              if (_isEditingMap[id]!) {
                final newText = _controllers[id]?.text.trim() ?? '';
                if (newText.isNotEmpty && newText != initialText) {
                  onSave(newText);
                }
                setState(() {
                  _isEditingMap[id] = false;
                });
              } else {
                setState(() {
                  _isEditingMap[id] = true;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(EvaIcons.trash2Outline, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStatusList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: taskStatusList.length,
      itemBuilder: (context, index) {
        final item = taskStatusList[index];
        final id = item.id ?? '';
        return _buildEditableItem(
          id: id,
          initialText: item.taskStatusName,
          onSave: (value) => sendToBackend(id, value),
          onDelete: () => deleteTaskStatus(id),
        );
      },
    );
  }

  Widget _buildRoleList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rolesList.length,
      itemBuilder: (context, index) {
        final item = rolesList[index];
        final id = item.id ?? '';
        return _buildEditableItem(
          id: id,
          initialText: item.roleName,
          onSave: (value) => updateRole(id, value),
          onDelete: () => deleteRole(id),
        );
      },
    );
  }

  Widget _buildUsersList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: usersList.length,
      itemBuilder: (context, index) {
        final user = usersList[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: const Icon(EvaIcons.person, color: Colors.blueAccent),
            title: Text(user.username),
            subtitle: Text('${user.firstName} ${user.lastName}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(EvaIcons.edit2Outline,
                      color: Colors.blue, size: 28),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => EditAccountDialog(user: user),
                  ),
                ),
                IconButton(
                  icon: const Icon(EvaIcons.personDeleteOutline,
                      color: Colors.red),
                  onPressed: () => _confirmDeleteUser(user),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EditAccountDialog extends StatefulWidget {
  final UserProfileDTO user;

  const EditAccountDialog({Key? key, required this.user}) : super(key: key);

  @override
  State<EditAccountDialog> createState() => _EditAccountDialog();
}

class _EditAccountDialog extends State<EditAccountDialog> with RouteAware{
  final _formKeySettings = GlobalKey<FormState>();
  final UserApi userApi = UserApi();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  String? _selectedRole;
  String? _selectedPermission;

  bool _updatePassword = false;

  List<String> rolesName = [];
  List<String> permissionsName = [];

  List<permissions> _permissionsList = [];
  List<roles> _rolesList = [];

  @override
  void initState() {
    super.initState();

    _usernameController.text = widget.user.username;
    _firstNameController.text = widget.user.firstName;
    _lastNameController.text = widget.user.lastName;
    _selectedRole = widget.user.role?.roleName;
    _selectedPermission = widget.user.permission?.permissionName;

    loadData();
  }

  Future<void> loadData() async {
    final permissionsResponse = await backend_services().fetchAllPermissions();
    final rolesResponse = await backend_services().fetchAllRoles();
    if (!mounted) return; // ✅ اضافه شود

    setState(() {
      _permissionsList = permissionsResponse.data ?? [];
      _rolesList = (rolesResponse.data ?? []).cast<roles>();
      permissionsName = _permissionsList.map((p) => p.permissionName).toList();
      rolesName = _rolesList.map((r) => r.roleName).toList();
    });
  }

  Future<void> updateUser() async {
    if (!_formKeySettings.currentState!.validate()) return;

    final username = _usernameController.text;
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;

    final roles foundRole = _rolesList.firstWhere(
      (r) => r.roleName == _selectedRole,
      orElse: () => roles(id: "null", roleName: "NotFound"),
    );

    final permissions foundPermission = _permissionsList.firstWhere(
      (p) => p.permissionName == _selectedPermission,
      orElse: () => permissions(id: "null", permissionName: "NotFound"),
    );

    final updateDto = UpdateUserDTO(
      userId: widget.user.userId,
      username: username,
      firstName: firstName,
      lastName: lastName,
      roleId: foundRole.id,
      permissionId: foundPermission.id,
      password: _updatePassword ? _passwordController.text : "",
      updatePassword: _updatePassword,
    );

    final response = await userApi.updateUser(updateDto);

    if (response.status == 'success') {
      StringHelper.showInfoDialog(context, "${response.message}");
    } else {
      StringHelper.showErrorDialog(
          context, "Güncelleme hatası: ${response.message}");
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
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKeySettings,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Personel Bilgilerini Güncelle",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Kullanıcı adı gerekli'
                      : null,
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Şifre',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        enabled: _updatePassword,
                        validator: (value) {
                          if (_updatePassword &&
                              (value == null || value.isEmpty)) {
                            return 'Lütfen şifreyi girin';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Checkbox(
                      value: _updatePassword,
                      onChanged: (bool? value) {
                        setState(() {
                          _updatePassword = value ?? false;
                          if (!_updatePassword) {
                            _passwordController.clear();
                          }
                        });
                      },
                    ),
                    const Text('Şifreyi Güncelle'),
                  ],
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Adı',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Adı gerekli' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Soyadı',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Soyadı gerekli'
                      : null,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  items: rolesName
                      .map((role) =>
                          DropdownMenuItem(value: role, child: Text(role)))
                      .toList(),
                  decoration: const InputDecoration(
                    labelText: 'Rol Seçin',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _selectedRole = value),
                  validator: (value) => value == null ? 'Rol gerekli' : null,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedPermission,
                  items: permissionsName
                      .map((perm) =>
                          DropdownMenuItem(value: perm, child: Text(perm)))
                      .toList(),
                  decoration: const InputDecoration(
                    labelText: 'Yetki Seviyesi',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) =>
                      setState(() => _selectedPermission = value),
                  validator: (value) => value == null ? 'Yetki gerekli' : null,
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
                        if (_formKeySettings.currentState!.validate()) {
                          await updateUser();
                        }
                      },
                      child: const Text('Güncelle'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
