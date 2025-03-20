import 'package:chat_app/auth/services/auth_services.dart';
import 'package:chat_app/auth/sign_up.dart';
import 'package:chat_app/widgets/custom_button.dart';
import 'package:chat_app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  // controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  //keys
  GlobalKey<FormState> emailFormState = GlobalKey();
  GlobalKey<FormState> passwordFormState = GlobalKey();

  // auth
  Future<void> signIn() async {
    var services = AuthServices();

    if (!RegExp(
          "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]",
        ).hasMatch(emailController.text) ||
        emailController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("enter valid email")));
      return;
    }

    if (passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("not valid.")));
      return;
    }

    services.signInWithEmailAndPassword(
      emailController.text,
      passwordController.text,
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome", style: GoogleFonts.inter(fontSize: 9.w)),
            SizedBox(height: 2.h),
            CustomTextField(
              formState: emailFormState,
              obscureText: false,
              controller: emailController,
              textInputType: TextInputType.emailAddress,
              hintText: 'Email',
              prefixIcon: Icon(Icons.person_rounded),
            ),

            // password
            CustomTextField(
              formState: passwordFormState,
              obscureText: true,
              controller: passwordController,
              textInputType: TextInputType.name,
              hintText: 'Password',
              prefixIcon: Icon(Icons.lock_outline_rounded),
            ),
            SizedBox(height: 2.h),
            CustomButton(
              onTap: () {
                signIn();
              },
              title: "SignIn",
              width: 100.w,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have account?",
                  style: GoogleFonts.rubik(color: const Color(0xff888686)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const SignUp()),
                    );
                  },
                  child: const Text(
                    'Create one',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
