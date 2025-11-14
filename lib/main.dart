import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([_initHive(), _initFirebase()]);

  runApp(const ProviderScope(child: ExpenseTrackerApp()));
}

Future<void> _initHive() async {
  await Hive.initFlutter();
  await Hive.openBox('transactions');
}

Future<void> _initFirebase() {
  return Firebase.initializeApp();
}
