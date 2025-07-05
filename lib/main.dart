import 'package:chat_app/auth/keys.dart';
import 'package:chat_app/auth/sign_in.dart';
import 'package:chat_app/components/custom_navigation_bar.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/services/stories_services.dart';
import 'package:chat_app/view/nav_bar_pages.dart/chat_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as s;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await s.Supabase.initialize(
    url: 'https://tjfiyddgeljrygtjgyov.supabase.co',
    anonKey: supbase_Key,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => StoriesServices()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home:
              FirebaseAuth.instance.currentUser == null
                  ? SignIn()
                  : CustomNavigationBar(),

          // FirebaseAuth.instance.currentUser == null ? SignIn() : HomePage(),
          routes: {
            'homePage': (context) => ChatPage(),
            "signIn": (context) => SignIn(),
          },
        );
      },
    );
  }
}
