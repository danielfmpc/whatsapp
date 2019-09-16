import 'package:cloud_firestore/cloud_firestore.dart';

class Conversa{
  String _idRemetente;
  String _idDestinatario;
  String _tipo;
  String _nome;
  String _mensagem;
  String _caminhoFoto;
  String _data;



  Conversa();

  salvar() async {
    Firestore db = Firestore.instance;
    await db.collection("conversas")
    .document(this.idRemetente)
    .collection("ultima_conversa")
    .document(this.idDestinatario)
    .setData(this.toMap());
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idRemetente": this.idRemetente,
      "idDestinatario": this.idDestinatario,
      "tipo": this.tipo,
      "nome": this.nome,
      "mensagem": this.mensagem,
      "caminhoFoto": this.caminhoFoto,
      "data": this.data,

    };
    return map;
  }

  String get data => _data;

  set data(String value) {
    _data = value;
  }


  String get idRemetente => _idRemetente;

  set idRemetente(String value) {
    _idRemetente = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get mensagem => _mensagem;

  String get caminhoFoto => _caminhoFoto;

  set caminhoFoto(String value) {
    _caminhoFoto = value;
  }

  set mensagem(String value) {
    _mensagem = value;
  }

  String get idDestinatario => _idDestinatario;

  set idDestinatario(String value) {
    _idDestinatario = value;
  }

  String get tipo => _tipo;

  set tipo(String value) {
    _tipo = value;
  }


}