import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'package:provider/provider.dart';
import 'providers/item_state.dart';
import 'providers/emotion_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ItemState()),
        ChangeNotifierProvider(create: (_) => EmotionState()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Office Leafy',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 224, 229, 225), // 深绿色作为主色调
            brightness: Brightness.light,
          ),
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: const Color(0xFFFFFCF5), // 温暖的米白色背景
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            color: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFFFCF5),
            elevation: 0,
            titleTextStyle: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        builder: (context, child) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFFCF5), // 更改为温暖的米白色
            ),
            child: child,
          );
        },
        home: const HomePage(),
      ),
    );
  }
}