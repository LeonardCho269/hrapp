import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_ht/responsive/main_screen.dart';
import 'package:responsive_ht/screens.dart/login_screen.dart';

class AppColors {
  static const Color backColor = Color.fromARGB(255, 122, 122, 122);
  static const Color mainBlueColor = Color.fromARGB(255, 36, 36, 36);
  static const Color blueDarkColor = Color.fromARGB(255, 214, 214, 214);
  static const Color textColor = Color.fromARGB(255, 197, 198, 202);
  static const Color greyColor = Color(0xffAAAAAA);
  static const Color whiteColor = Color(0xffFFFFFF);
}

TextStyle ralewayStyle = GoogleFonts.montserrat();

var myDefaultBackgroundColor = Colors.grey[300];

Widget myDrawer(BuildContext context) {
  return Drawer(
    child: Theme(
      data: Theme.of(context).copyWith(
        iconTheme: const IconThemeData(color: Colors.white), // установите цвет иконки здесь
      ),
      child: ListView(
        children: [
          const DrawerHeader(child: Icon(Icons.home)),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text('Главная',
                style: ralewayStyle.copyWith(
                  fontSize: 22.0,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                )),
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const YourMainScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: Text('Новости',
                style: ralewayStyle.copyWith(
                  fontSize: 22.0,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                )),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text('Настройки',
                style: ralewayStyle.copyWith(
                  fontSize: 22.0,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                )),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text('Выйти',
                style: ralewayStyle.copyWith(
                  fontSize: 22.0,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                )),
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
        ],
      ),
    ),
  );
}
