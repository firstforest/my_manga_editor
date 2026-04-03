import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_manga_editor/feature/auth/view/sign_in_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book, size: 64.r, color: Colors.deepPurple),
            SizedBox(height: 16.r),
            Text(
              'My Manga Editor',
              style: TextStyle(fontSize: 32.r, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.r),
            Text(
              'ログインして始めましょう',
              style: TextStyle(fontSize: 16.r, color: Colors.grey),
            ),
            SizedBox(height: 32.r),
            const SignInButton(),
          ],
        ),
      ),
    );
  }
}
