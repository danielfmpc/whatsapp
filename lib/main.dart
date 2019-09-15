import 'package:flutter/material.dart';
import 'package:whatsapp/Login.dart';
import 'package:whatsapp/RouteGenerator.dart';
import 'dart:io';

final ThemeData temaPadrao = ThemeData(
  primaryColor: Color(0xff075E54),
  accentColor: Color(0xff25D366)
);
final ThemeData temaIos = ThemeData(
  primaryColor: Colors.grey[200],
  accentColor: Color(0xff25D366)
);

void main() {

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(),
      theme: Platform.isIOS ? temaIos : temaPadrao,
      initialRoute: "/",
      onGenerateRoute: RouteGenerator.generateRoute,
    ),
  );
}

