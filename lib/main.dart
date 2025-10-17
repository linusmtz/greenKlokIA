import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const GreenKlokIA());
}

class GreenKlokIA extends StatelessWidget {
  const GreenKlokIA({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title :"GreenKlokIA",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true
      ),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes
    );
  }
}
 