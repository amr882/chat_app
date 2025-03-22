import 'package:chat_app/auth/services/auth_services.dart';
import 'package:chat_app/widgets/custom_button.dart';
import 'package:chat_app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  //keys
  GlobalKey<FormState> nameFormState = GlobalKey();
  GlobalKey<FormState> emailFormState = GlobalKey();
  GlobalKey<FormState> passwordFormState = GlobalKey();
  GlobalKey<FormState> confirnPasswordFormState = GlobalKey();
  // auth
  Future<void> signUp() async {
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
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("password not match")));
      return;
    }

    services.createAccount(
      nameController.text,
      emailController.text,
      confirmPasswordController.text,
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Create a \nnew account",
                style: GoogleFonts.inter(fontSize: 9.w),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              // userName
              CustomTextField(
                formState: nameFormState,
                obscureText: false,
                controller: nameController,
                textInputType: TextInputType.name,
                hintText: 'Name',
                prefixIcon: Icon(Icons.person_rounded),
              ),

              // email
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
              // confirm password
              CustomTextField(
                formState: confirnPasswordFormState,
                obscureText: true,
                controller: confirmPasswordController,
                textInputType: TextInputType.name,
                hintText: 'Confirm Password',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
              SizedBox(height: 2.h),

              CustomButton(
                onTap: () {
                  signUp();
                },
                title: "SignUp",
                width: 100.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
