import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Configuracoes extends StatefulWidget {
  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  TextEditingController _controllerNome = TextEditingController();
  File _imagem;
  String _idUsuarioLogado;
  bool _subindoImagem = false;
  String _urlImageRecuperada;

  Future _recuperarImage(String origemImagem) async {
    File imageSelecionada;
    switch (origemImagem){
      case "camera":
        imageSelecionada = await ImagePicker.pickImage(source: ImageSource.camera);
        break;
      case "galeria":
        imageSelecionada = await ImagePicker.pickImage(source: ImageSource.gallery);
        break;
    }

    setState(() {
      _imagem = imageSelecionada;
      if(_imagem != null){
        _subindoImagem = true;
        _uploadImage();
      }
    });
  }

  Future _uploadImage() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz
    .child("perfil")
    .child(_idUsuarioLogado + ".jpg");

    StorageUploadTask task = arquivo.putFile(_imagem);

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
    _atualizarUrlImagemFirestore(url);
    setState(() {
      _urlImageRecuperada = url;
    });
  }

  _atualizarNomeFirestore(){
    Firestore db = Firestore.instance;
    String nome = _controllerNome.text;
    Map<String, dynamic>dadosAtualzizar = {
      "nome": nome
    };

    db.collection("usuarios")
        .document(_idUsuarioLogado)
        .updateData(
        dadosAtualzizar
    );
  }

  _atualizarUrlImagemFirestore(String url){
    Firestore db = Firestore.instance;

    Map<String, dynamic>dadosAtualzizar = {
      "urlImage": url
    };

    db.collection("usuarios")
    .document(_idUsuarioLogado)
    .updateData(
        dadosAtualzizar
    );
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;

    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot = await db.collection("usuarios")
    .document(_idUsuarioLogado)
    .get();

    Map<String, dynamic>dados = snapshot.data;
    _controllerNome.text = dados["nome"];

    if(dados["urlImage"] != null){
      setState(() {
        _urlImageRecuperada = dados["urlImage"];
      });
    }
  }



  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configuracoes"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(16),

                  child: _subindoImagem ? CircularProgressIndicator() : Container(),
                ),
                CircleAvatar(
                  radius: 100,
//                child: _subindoImagem ? CircularProgressIndicator() : Container(child: Column(children: <Widget>[CircleAvatar(backgroundColor: Colors.grey, radius: 100, backgroundImage: _urlImageRecuperada != null ? NetworkImage(_urlImageRecuperada) : null)],),) ,
                  backgroundColor: Colors.grey,
                  backgroundImage: _urlImageRecuperada != null ? NetworkImage(_urlImageRecuperada) : null,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      child: Text("Câmera"),
                      onPressed: (){
                        _recuperarImage("camera");
                      },
                    ),
                    FlatButton(
                      child: Text("Galeria"),
                      onPressed: (){
                        _recuperarImage("galeria");
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: TextField(
                    controller: _controllerNome,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
//                    onChanged: (texto){
//                      _atualizarNomeFirestore(texto);
//                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Nome",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                    onPressed: () {
                      _atualizarNomeFirestore();
                    },
                    child: Text(
                      "Salvar",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    color: Colors.green,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
