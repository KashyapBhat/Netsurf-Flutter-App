import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

Future<void> setupDependencies() async {
  FirebaseApp app = await Firebase.initializeApp();
  GetIt.I.registerSingleton<FirebaseApp>(app);
  GetIt.I.registerSingleton<FirebaseAnalytics>(FirebaseAnalytics.instance);
  GetIt.I.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
}