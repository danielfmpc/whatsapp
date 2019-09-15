import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/Usuario.dart';

class Conversas extends StatefulWidget {
  @override
  _ConversasState createState() => _ConversasState();
}

class _ConversasState extends State<Conversas> {
  Firestore db = Firestore.instance;
  String _idUsuarioLogado;
  // ignore: close_sinks  
  final _controller = StreamController<QuerySnapshot>.broadcast();

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;
    _adicionarListenerCoversas();

  }

  Stream<QuerySnapshot> _adicionarListenerCoversas(){
    final stream = db.collection("conversas")
    .document(_idUsuarioLogado)
    .collection("ultima_conversa")
    .snapshots();

    stream.listen((dados){
      _controller.add(dados);
    });

  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
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
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, indice){
                  List<DocumentSnapshot> conversas = querySnapshot.documents.toList();
                  DocumentSnapshot item = conversas[indice];
                  String url = item["caminhoFoto"];
                  String mensagem = item["mensagem"];
                  String tipo = item["tipo"];
                  String nome = item["nome"];
                  String idDestinatario = item["idDestinatario"];

                  Usuario usuario = Usuario();
                  usuario.nome = nome ;
                  usuario.idUsuario = idDestinatario;
                  usuario.urlImagem = url;

                  return ListTile(
                     onTap: (){
                      Navigator.pushNamed(context, "/mensagens", arguments: usuario);
                    },
                    contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    leading: CircleAvatar(
                      maxRadius: 30,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage( url ),
                    ),
                    title: Text(
                      nome,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                      ),
                    ),
                    subtitle: Text(
                        tipo == "texto"
                        ? mensagem
                        : "Imagem ...",
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
