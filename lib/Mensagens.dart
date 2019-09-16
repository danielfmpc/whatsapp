import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp/model/Conversa.dart';
import 'package:whatsapp/model/Mensagem.dart';
import 'package:whatsapp/model/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class Mensagens extends StatefulWidget {
  Usuario contato;
  bool isMe;
  Mensagens(this.contato, {this.isMe});

  @override
  _MensagensState createState() => _MensagensState();
//  final icon = delivered ? Icons.done_all : Icons.done;
}

class _MensagensState extends State<Mensagens> {
  bool _subindoImagem = false;
  Firestore db = Firestore.instance;
  TextEditingController _controllerMensagem = TextEditingController();
  String _idUsuarioLogado;
  String _idUsuarioDestinatario;
  String _data = DateTime.now().second.toString();

  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollController = ScrollController();

  Stream<QuerySnapshot> _adicionarListenerMensagem(){
    final stream = db
          .collection("mensagens")
          .document(_idUsuarioLogado)
          .collection(_idUsuarioDestinatario)
          .orderBy("data", descending: false)
          .snapshots();

    stream.listen((dados){
      _controller.add(dados);
      Timer(Duration(seconds: 1), (){
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });

  }

  _enviarMensagem() {
    String textoMensagem = _controllerMensagem.text;
    if (textoMensagem.isNotEmpty) {
      Mensagem mensagem = Mensagem();
      mensagem.idUsuario = _idUsuarioLogado;
      mensagem.mensagem = textoMensagem;
      mensagem.urlImagem = "";
      mensagem.tipo = "texto";
      mensagem.data = _data;

      // Salvar mensagem para o remetente
      _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);
      // Salvar mensagem para o destinatario
      _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);

      // Salvar conversa
      _salvarConversa(mensagem);
    }
  }

  _salvarConversa(Mensagem msg){
    // Salvar mensagem para o remetente
    Conversa cRemetente = Conversa();
    cRemetente.idRemetente = _idUsuarioLogado;
    cRemetente.idDestinatario = _idUsuarioDestinatario;
    cRemetente.mensagem = msg.mensagem;
    cRemetente.nome = widget.contato.nome;
    cRemetente.caminhoFoto = widget.contato.urlImagem;
    cRemetente.tipo = msg.tipo;
    cRemetente.data = msg.data;
    cRemetente.salvar();

    // Salvar mensagem para o destinatario
    Conversa cDestinatario = Conversa();
    cDestinatario.idRemetente = _idUsuarioDestinatario;
    cDestinatario.idDestinatario = _idUsuarioLogado;
    cDestinatario.mensagem = msg.mensagem;
    cDestinatario.nome = widget.contato.nome;
    cDestinatario.caminhoFoto = widget.contato.urlImagem;
    cDestinatario.tipo = msg.tipo;
    cDestinatario.data = msg.data;
    cDestinatario.salvar();
  }

  _salvarMensagem(String idRemetente,String idDestinatario, Mensagem msg) async {
    await db
        .collection("mensagens")
        .document(idRemetente)
        .collection(idDestinatario)
        .add(msg.toMap());

    _controllerMensagem.clear();
  }

  _enviarFoto() async {
    File imageSelecionada;
    imageSelecionada = await ImagePicker.pickImage(source: ImageSource.camera);
    _subindoImagem = true;
    String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz
        .child("mensagens")
        .child(_idUsuarioLogado)
        .child(nomeImagem + ".jpg");

    StorageUploadTask task = arquivo.putFile(imageSelecionada);

    task.events.listen((StorageTaskEvent storageTaskEvent){
      if(storageTaskEvent.type == StorageTaskEventType.progress){
        setState(() {
          _subindoImagem = true;
        });
      } else if(storageTaskEvent.type == StorageTaskEventType.success) {
        _subindoImagem = false;
      }
    });

    task.onComplete.then((StorageTaskSnapshot snapshot){
      _recuperarUrlImage(snapshot);

    });

  }

  Future _recuperarUrlImage(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    Mensagem mensagem = Mensagem();
    mensagem.idUsuario = _idUsuarioLogado;
    mensagem.mensagem = "";
    mensagem.urlImagem = url;
    mensagem.tipo = "imagem";

    // Salvar mensagem para o remetente
    _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);
    // Salvar mensagem para o destinatario
    _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;
    _idUsuarioDestinatario = widget.contato.idUsuario;
    _adicionarListenerMensagem();
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {

    var caixaMensagem = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: TextField(
                controller: _controllerMensagem,
                autofocus: true,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Digite uma mensagem...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    suffixIcon: _subindoImagem ?
                    CircularProgressIndicator()
                    : IconButton(icon: Icon(Icons.camera_alt), onPressed: _enviarFoto)),
              ),
            ),
          ),
          Platform.isIOS ? CupertinoButton(
            onPressed: _enviarMensagem,
            child: Text("Enviar"),

          )
          : 
          FloatingActionButton(
            onPressed: _enviarMensagem,
            backgroundColor: Color(0xff075E54),
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
            mini: true,
          ),
        ],
      ),
    );
    var stream = StreamBuilder(
      stream: _controller.stream,
      // ignore: missing_return
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando mensagens"),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            QuerySnapshot querySnapshot = snapshot.data;
            if (snapshot.hasError) {
              return Expanded(
                child: Text("Erro ao carregar os dados!"),
              );
            } else {
              return Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                    itemCount: querySnapshot.documents.length,
                    itemBuilder: (context, indice) {
                      List<DocumentSnapshot> mensagens = querySnapshot.documents.toList();
                      DocumentSnapshot item = mensagens[indice];

                      double larguraContainer = MediaQuery.of(context).size.width * 0.8;
                      Alignment alignment = Alignment.centerRight;
                      Color color = Color(0xffd2ffa5);

                      if (_idUsuarioLogado != item["idUsuario"]) {
                        alignment = Alignment.centerLeft;
                        color = Colors.white;
                        widget.isMe = true;
                      } else {
                        widget.isMe = false;

                      }
                      return Align(
                        alignment: alignment,
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Container(
                            width: larguraContainer,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: .5,
                                      spreadRadius: 1.0,
                                      color: Colors.black.withOpacity(.12))
                                ],
                                color: color,
                                borderRadius: widget.isMe
                                      ? BorderRadius.only(
                                          topRight: Radius.circular(5.0),
                                      bottomLeft: Radius.circular(10.0),
                                      bottomRight: Radius.circular(5.0),
                                    )
                                          : BorderRadius.only(
                                  topLeft: Radius.circular(5.0),
                                  bottomLeft: Radius.circular(5.0),
                                  bottomRight: Radius.circular(10.0),
                                ),
                            ),

                            child: item["tipo"] == "texto" ? Text(item["mensagem"],style: TextStyle(fontSize: 18),)
                                : Image.network(item["urlImagem"]),
                          ),
                        ),
                      );
                    }),
              );
            }
            break;
        }
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              maxRadius: 20,
              backgroundColor: Colors.grey,
              backgroundImage: widget.contato.urlImagem != null
                  ? NetworkImage(widget.contato.urlImagem)
                  : null,
            ),
            Container(
                padding: const EdgeInsets.all(8.0),
                child: Text(widget.contato.nome))
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage("images/bg.png"),
          fit: BoxFit.cover,
        )),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                stream,
                // caixa de mensagem,
                caixaMensagem,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
