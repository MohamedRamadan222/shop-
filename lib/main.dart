import 'package:fleehshop/widgets/grocery_list.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery List',
      theme: ThemeData.dark().copyWith(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            surface: Colors.cyan,
          ),
          scaffoldBackgroundColor: Colors.grey[800],
          useMaterial3: true),
      home: const GroceryList(),
    );
  }
}
