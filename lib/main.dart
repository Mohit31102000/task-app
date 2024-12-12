import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_app/model/user_model.dart';
import 'package:task_app/provider/network_provider.dart';
import 'package:task_app/provider/user_list_provider.dart';
import 'package:task_app/screens/home_screen.dart';
import 'package:task_app/screens/login_screen.dart';
import 'package:task_app/screens/splash_screen.dart';
import 'package:task_app/screens/user_detail_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserListProvider()),
        ChangeNotifierProvider(create: (_) => NetworkProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Internet Connection Listener
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    monitorInternetConnection();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel(); // Dispose connectivity subscription
    super.dispose();
  }

  // Monitor Internet Connection Changes
  void monitorInternetConnection() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      if (result[0] == ConnectivityResult.none) {
        // Internet OFF
        showSnackBar(context, "You are offline", Colors.red);
        debugPrint(
          "You are offline",
        );
      } else {
        // Internet ON
        showSnackBar(context, "You are online", Colors.green);
        debugPrint(
          "You are online",
        );
      }
    });
  }

  void showSnackBar(BuildContext context, String message, Color color) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Show SnackBar
  // void showSnackBar(String message, Color color) {
  //   if (mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(message),
  //         backgroundColor: color,
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'Task App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //  home: checkUserIdHasOrNot() == true ? HomeScreen() : LoginScreen(),
      home: SplashScreen(),
    );
  }
}
