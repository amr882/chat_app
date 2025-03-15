import 'package:chat_app/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  // controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  //keys
  GlobalKey<FormState> emailFormState = GlobalKey();
  GlobalKey<FormState> passwordFormState = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome", style: GoogleFonts.inter(fontSize: 9.w)),
            CustomTextField(
              formState: emailFormState,
              obscureText: false,
              controller: emailController,
              textInputType: TextInputType.emailAddress,
              hintText: 'Enter your email here',
              prefixIcon: Icon(Icons.person_rounded),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'not valid.';
                }
                if (!RegExp(
                  "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]",
                ).hasMatch(value)) {
                  return 'enter valid email';
                }
                return null;
              },
            ),

            // password
            CustomTextField(
              formState: passwordFormState,
              obscureText: true,
              controller: passwordController,
              textInputType: TextInputType.name,
              hintText: 'Enter Password',
              prefixIcon: Icon(Icons.lock_outline_rounded),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'not valid.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
