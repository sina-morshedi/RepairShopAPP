import 'package:flutter/material.dart';

class RegisterNewJobPage extends StatelessWidget {
  const RegisterNewJobPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.work_outline, size: 100, color: Colors.deepPurple),
          SizedBox(height: 20),
          Text('Register a New Job', style: TextStyle(fontSize: 22)),
        ],
      ),
    );
  }
}