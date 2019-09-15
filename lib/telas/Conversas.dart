import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/Conversa.dart';

class Conversas extends StatefulWidget {
  @override
  _ConversasState createState() => _ConversasState();
}

class _ConversasState extends State<Conversas> {
  // ignore: close_sinks
  final _controller = StreamController<QuerySnapshot>.broadcast(

  );
  List<Conversa> _listaConversas = List();
  @override
  void initState() {
    super.initState();
    Conversa conversa = Conversa();
    conversa.nome ="Ana Clara";
    conversa.mensagem = "Olá, blz";
    conversa.caminhoFoto = "";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _controller.stream,
      // ignore: missing_return
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando conversas"),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
          if (snapshot.hasError) {
            return Text("Erro ao carregar os dados!");
          } else {
            QuerySnapshot querySnapshot = snapshot.data;
            if (querySnapshot.documents.length == 0) {
              return Center(
                child: Text(
                  "Você não tem nenhuma mensagem ainda :C",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
              );
            }
            return ListView.builder(
                itemCount: _listaConversas.length,
                itemBuilder: (context, indice){
                  Conversa conversa = _listaConversas[indice];
                  return ListTile(
                    contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    leading: CircleAvatar(
                      maxRadius: 30,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage( conversa.caminhoFoto ),
                    ),
                    title: Text(
                      conversa.nome,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                      ),
                    ),
                    subtitle: Text(
                        conversa.mensagem,
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14
                        )
                    ),
                  );
                }
            );
          }
        }
      }
    );
  }
}
