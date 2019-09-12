import 'package:flutter/material.dart';
import 'package:whatsapp/Home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  Firestore.instance
  .collection("usuarios")
  .document("001")
  .setData({"nome": "Daniel Fernando"});
  
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
      theme: ThemeData(
        primaryColor: Color(0xff075E54),
        accentColor: Color(0xff25D366)
      ),
    ),
  );
}

