import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_ht/components/api_services.dart';
import 'package:responsive_ht/responsive/home_page_data.dart';
import 'package:responsive_ht/screens.dart/login_screen.dart';  

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Dio dio = Dio();
  ApiService authService = ApiService(dio: dio);

  await authService.checkTokenValidity();

  runApp(MyApp(authService: authService));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class AuthState {
  bool isAuthenticated = false;
}

class MyApp extends StatelessWidget {
  final ApiService authService;

  const MyApp({required this.authService, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: authService.isRefreshTokenValid ? const MyHomePage() : const LoginScreen(),
    );
  }
}
