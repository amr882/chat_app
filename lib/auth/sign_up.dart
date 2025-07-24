// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:chat_app/auth/services/auth_services.dart';
import 'package:chat_app/widgets/custom_button.dart';
import 'package:chat_app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  String pfpUrl =
      "https://tjfiyddgeljrygtjgyov.supabase.co/storage/v1/object/public/chatpfp/uploads/userpfp.jpg";
  bool isLoading = false;
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
      pfpUrl,
    );
  }

  File? imageFile;

  pickImage() async {
    ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      imageFile = File(image.path);
      setState(() {
        isLoading = true;
      });
      await uploadImage();
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> uploadImage() async {
    if (imageFile == null) return;
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = "uploads/$fileName";
    try {
      await Supabase.instance.client.storage
          .from("chatpfp")
          .upload(path, imageFile!);
      final res = Supabase.instance.client.storage
          .from('chatpfp')
          .getPublicUrl('uploads/$fileName');
      if (mounted) {
        setState(() {
          pfpUrl = res;
        });
      }
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to upload image.")));
      setState(() {
        isLoading = false;
      });
    }
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
                style: GoogleFonts.inter(fontSize: 7.w),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              GestureDetector(
                onTap: () {
                  pickImage();
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: const Color.fromARGB(255, 196, 193, 193),
                  ),
                  width: 12.h,
                  height: 12.h,
                  child: Center(
                    child:
                        imageFile == null
                            ? Icon(Icons.upload_rounded, color: Colors.white)
                            : isLoading
                            ? Center(child: CircularProgressIndicator())
                            : ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(
                                pfpUrl,
                                fit: BoxFit.cover,
                                width: 12.h,
                                height: 12.h,
                              ),
                            ),
                  ),
                ),
              ),

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
