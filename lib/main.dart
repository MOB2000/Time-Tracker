import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/services/database.dart';

import 'app/landing_page.dart';
import 'services/auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error :(');
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Provider<AuthBase>(
            create: (context) => Auth(),
            child: MaterialApp(
              title: 'Time Tracker',
              theme: ThemeData(
                primarySwatch: Colors.indigo,
              ).copyWith(),
              home: LandingPage(
                databaseBuilder: (uid) => FirestoreDatabase(uid: uid),
              ),
            ),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
