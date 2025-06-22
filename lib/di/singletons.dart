import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

import '../common/contants.dart';
import '../common/models/customer.dart';
import '../common/models/display_data.dart';
import '../common/product_constant.dart';
import '../common/sp_constants.dart';
import '../common/sp_utils.dart';

Future<void> setupDependencies() async {
  await setupFirebase();
  await setupDisplayData();
  await setupBillingID();
  await setupRetailerDetails();
}

Future<void> setupDisplayData() async {
  FirebaseFirestore fireStore = GetIt.I.get<FirebaseFirestore>();
  DisplayData? displayData = await Products.getDisplayData(fireStore, false);
  if (displayData != null) GetIt.I.registerSingleton<DisplayData>(displayData);
}

Future<void> setupFirebase() async {
  FirebaseApp app = await Firebase.initializeApp();
  GetIt.I.registerSingleton<FirebaseApp>(app);
  GetIt.I.registerSingleton<FirebaseAnalytics>(FirebaseAnalytics.instance);
  GetIt.I.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
}

Future<void> setupBillingID() async {
  String? billingId = await Preference.getItem(SP_BILLING_ID);
  if (billingId.isNotEmpty) {
    int lastBillID = int.parse(billingId);
    billingId = (++lastBillID).toString();
  } else {
    billingId = BILLING_ID_START;
  }
  GetIt.I.registerSingleton<String>(billingId, instanceName: BILLING_ID);
}

Future<void> setupRetailerDetails() async {
  if (GetIt.instance.isRegistered<User>()) GetIt.instance.unregister<User>();
  User? user = await Preference.getRetailer();
  if (user == null) user = User("", "", "", "", "");
  GetIt.I.registerSingleton<User>(user);
}
