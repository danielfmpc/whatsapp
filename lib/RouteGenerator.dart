import 'package:flutter/material.dart';
import 'package:whatsapp/Cadastro.dart';
import 'package:whatsapp/Configuracoes.dart';
import 'package:whatsapp/Home.dart';
import 'package:whatsapp/Login.dart';
import 'package:whatsapp/Mensagens.dart';

class RouteGenerator {
//  static const String ROTA_HOME = "/home";
  // ignore: missing_return
  static Route<dynamic> generateRoute(RouteSettings settings){
    final args = settings.arguments;
    switch (settings.name){
      case "/":
        return MaterialPageRoute(builder: (_) =>Login());
        break;
      case "/login":
        return MaterialPageRoute(builder: (_) =>Login());
        break;
      case "/cadastro":
        return MaterialPageRoute(builder: (_) =>Cadastro());
        break;
      case "/home":
        return MaterialPageRoute(builder: (_) =>Home());
        break;
      case "/configuracoes":
        return MaterialPageRoute(builder: (_) =>Configuracoes());
        break;
      case "/mensagens":
        return MaterialPageRoute(builder: (_) =>Mensagens(args));
        break;
      default:
        _erroRota();

    }
  }
  static Route<dynamic> _erroRota(){
    return MaterialPageRoute(
      builder: (_){
        return Scaffold(
          appBar: AppBar(
            title: Text("Tela não encontrada"),
          ),
          body: Center(
            child: Text("Tela não encontrada"),
          ),
        );
      }
    );
  }
}