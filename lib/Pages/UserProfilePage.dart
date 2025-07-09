import 'package:autonetwork/DTO/CarRepairLogResponseDTO.dart';
import 'package:autonetwork/Pages/Components/CarRepairLogListView.dart';
import 'package:flutter/material.dart';
import '../type.dart';
import 'dart:ui';
import '../dboAPI.dart';
import 'user_prefs.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../backend_services/backend_services.dart';

import 'package:autonetwork/utils/string_helper.dart';
import 'package:autonetwork/DTO/UserProfileDTO.dart';
import 'package:autonetwork/DTO/CarRepairLogRequestDTO.dart';
import 'package:autonetwork/DTO/TaskStatusUserRequestDTO.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  List<CarRepairLogResponseDTO> logs = [];

  String first_name = '';
  String last_name = '';
  String role_name = '';

  void reloadUserData() {
    _loadUser();
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
    _loadUser();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadUser() async {
    UserProfileDTO? user = await UserPrefs.getUserWithID();
    dboAPI api = dboAPI();

    if (user != null && user.role != null && user.permission != null) {
      setState(() {
        first_name = user.firstName;
        last_name = user.lastName;
        role_name = user.role!.roleName;
      });
    } else {
      debugPrint("user or one of its nested fields is null");
    }
    final request = TaskStatusUserRequestDTO(
      assignedUserId: user!.userId,
      taskStatusNames: ["BAŞLANGIÇ", "DURAKLAT", "USTA"],
    );
    final response = await CarRepairLogApi().getLatestLogsByTaskStatusesAndUserId(request);
    if(response.status == 'success'){
      setState(() {
        logs = response.data!;
      });
    }
    else
      StringHelper.showErrorDialog(context, response.message!);
  }

  Future<String> _getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  void _handleLogButtonPressed(CarRepairLogResponseDTO log) async{
    final user = await UserPrefs.getUserWithID();
    
    final responseTask = await TaskStatusApi().getTaskStatusByName("BAŞLANGIÇ");
    if(responseTask.status == 'success'){
      final request = CarRepairLogRequestDTO(
          carId: log.carInfo.id,
          creatorUserId: user!.userId,
          taskStatusId: responseTask.data!.id!,
          problemReportId: log.problemReport!.id,
          assignedUserId: log.assignedUser!.userId,
          description: log.description,
          dateTime: DateTime.now());

      final response = await CarRepairLogApi().createLog(request);
      if(response.status == 'success')
        StringHelper.showInfoDialog(context, 'Bilgiler kaydedildi.');
      else
        StringHelper.showErrorDialog(context, response.message!);
    }
    else{
      StringHelper.showErrorDialog(context, responseTask.message!);
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Row(
                    children: [
                      // first_name و last_name کنار هم
                      Text(
                        '$first_name $last_name',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),

                      Spacer(),

                      // role_name سمت راست کامل
                      Text(
                        role_name,
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),
              Text(
                "Çalışanın Görevleri",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Expanded(
                child: CarRepairLogListView(
                  logs: logs,
                  buttonBuilder: (log) {
                    return {
                      'text': 'İşe başlıyorum.',
                      'onPressed': () {
                        _handleLogButtonPressed(log);
                      },
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}


