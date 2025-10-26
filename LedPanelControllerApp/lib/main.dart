import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/panel_controller_provider.dart';
import 'screens/connection_screen.dart';

void main() {
  runApp(const LedPanelApp());
}

class LedPanelApp extends StatelessWidget {
  const LedPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PanelControllerProvider(),
      child: MaterialApp(
        title: 'LED Panel Controller',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        home: const ConnectionScreen(),
      ),
    );
  }
}
