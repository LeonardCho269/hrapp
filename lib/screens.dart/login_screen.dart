import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:responsive_ht/components/api_services.dart';
import 'package:responsive_ht/constants.dart';
import 'package:responsive_ht/responsive/main_screen.dart';
import 'package:responsive_ht/screens.dart/responsive_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late ApiService apiService;
  bool isLoggingIn = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    apiService = ApiService(dio: Dio());
  }

  Future<void> sendLoginRequest() async {
    try {
      if (_formKey.currentState!.validate() && !isLoggingIn) {
        _startLogin();
        final username = _usernameController.text;
        final password = _passwordController.text;

        await apiService.login(username, password);

        if (apiService.isLoggedIn) {
          await apiService.gettingAccessToken();
          _navigateToDashboard();
        } else {
          _showErrorSnackBar('Вы ввели неверный логин/пароль');
        }
      }
    } catch (e) {
      _handleError(e);
    } finally {
      _finishLogin();
    }
  }

  void _startLogin() => setState(() => isLoggingIn = true);

  void _navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const YourMainScreen(),
      ),
    );
  }

  void _handleError(dynamic e) => _showErrorSnackBar('Вы ввели неверный логин/пароль');

  void _finishLogin() => setState(() => isLoggingIn = false);

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.backColor,
      body: SizedBox(
        height: height,
        width: width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ResponsiveWidget.isSmallScreen(context)
                ? const SizedBox()
                : Expanded(
                    child: Container(
                      height: height,
                      color: AppColors.mainBlueColor,
                      child: Center(
                        child: Text(
                          'HR HUB',
                          style: ralewayStyle.copyWith(
                            fontSize: 48.0,
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
            Expanded(
              child: Container(
                height: height,
                margin: EdgeInsets.symmetric(
                    horizontal: ResponsiveWidget.isSmallScreen(context) ? height * 0.032 : height * 0.12),
                color: AppColors.backColor,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: height * 0.25),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Войдите",
                                style: ralewayStyle.copyWith(
                                  fontSize: 25.0,
                                  color: AppColors.blueDarkColor,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              TextSpan(
                                text: " В Систему",
                                style: ralewayStyle.copyWith(
                                  fontSize: 25.0,
                                  color: AppColors.blueDarkColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        Text(
                          'Данный ресурс создан для обработки \nзаявок от аппликантов.',
                          style: ralewayStyle.copyWith(
                            fontSize: 12.0,
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: height * 0.04),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                            'Логин',
                            style: ralewayStyle.copyWith(
                              fontSize: 12.0,
                              color: AppColors.blueDarkColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Container(
                          height: 50.0,
                          width: width,
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: TextFormField(
                            controller: _usernameController,
                            validator: (value) => value == null || value.isEmpty ? 'Введите логин' : null,
                            style: ralewayStyle.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 12.0,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.email_outlined,
                                  color: AppColors.blueDarkColor,
                                ),
                              ),
                              contentPadding: const EdgeInsets.only(top: 16.0),
                              hintText: 'Введите логин',
                              hintStyle: ralewayStyle.copyWith(
                                color: AppColors.blueDarkColor.withOpacity(0.5),
                                fontWeight: FontWeight.w400,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.014),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                            'Пароль',
                            style: ralewayStyle.copyWith(
                              fontSize: 12.0,
                              color: AppColors.blueDarkColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Container(
                          height: 50.0,
                          width: width,
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            validator: (value) => value == null || value.isEmpty ? 'Введите пароль' : null,
                            style: ralewayStyle.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 12.0,
                            ),
                            obscureText: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.visibility_off_outlined,
                                  color: AppColors.blueDarkColor,
                                ),
                              ),
                              prefixIcon: IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.lock_outlined,
                                  color: AppColors.blueDarkColor,
                                ),
                              ),
                              contentPadding: const EdgeInsets.only(top: 16.0),
                              hintText: 'Введите пароль',
                              hintStyle: ralewayStyle.copyWith(
                                color: AppColors.blueDarkColor.withOpacity(0.5),
                                fontWeight: FontWeight.w400,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.064),
                        SizedBox(
                          width: 200.0,
                          height: 50.0,
                          child: ElevatedButton(
                            onPressed: () => sendLoginRequest(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mainBlueColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Войти',
                                style: ralewayStyle.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.whiteColor,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              errorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
