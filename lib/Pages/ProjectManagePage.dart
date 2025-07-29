import 'package:flutter/material.dart';
import 'ProjectManageForm.dart';
import 'RepairmenLogListTab.dart';

class ProjectManagePage extends StatefulWidget {
  const ProjectManagePage({super.key});

  @override
  _ProjectManagePageState createState() => _ProjectManagePageState();
}

class _ProjectManagePageState extends State<ProjectManagePage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: Colors.blue,
              tabs: [
                Tab(text: "Tüm Onarımlar"),
                Tab(text: "Usta Seç"),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(child: RepairmenLogListTab()),
                  ProjectmanageForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
