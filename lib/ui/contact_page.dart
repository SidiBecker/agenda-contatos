import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  bool _userEdited = false;
  Contact _editedContact;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());

      setState(() {
        _nameController.text = _editedContact.name;
        _emailController.text = _editedContact.email;
        _phoneController.text = _editedContact.phone;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _requestPop,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.deepPurple,
            title: Text(_editedContact.name ?? "Novo Contato"),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              bool valid = true;
              FocusNode focusNode = FocusNode();

              void fieldValidate(String valueField, FocusNode focus) {
                if (valid && (valueField == null || valueField.isEmpty)) {
                  valid = false;
                  focusNode = focus;
                }
              }

              fieldValidate(_editedContact.name, _nameFocus);
              fieldValidate(_editedContact.email, _emailFocus);
              fieldValidate(_editedContact.phone, _phoneFocus);

              if (!valid) {
                //Coloca o foco no campo inválido
                FocusScope.of(context).requestFocus(focusNode);
              } else {
                //TODO: Salvar o objeto nesta página
                Navigator.pop(context, _editedContact);
              }
            },
            child: Icon(Icons.save),
            backgroundColor: Colors.deepPurple,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    width: 80.0,
                    height: 80.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: _editedContact.img != null
                                ? FileImage(File(_editedContact.img))
                                : AssetImage("images/contact_default.png"))),
                  ),
                  onTap: () {
                    ImagePicker imagePicker = ImagePicker();
                    imagePicker
                        .getImage(source: ImageSource.camera)
                        .then((file) {
                      if (file == null) return;

                      setState(() {
                        _editedContact.img = file.path;
                      });
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Name"),
                  focusNode: _nameFocus,
                  onChanged: (text) {
                    _userEdited = true;

                    setState(() {
                      _editedContact.name = text;
                    });
                  },
                  controller: _nameController,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Email"),
                  focusNode: _emailFocus,
                  onChanged: (text) {
                    _userEdited = true;

                    setState(() {
                      _editedContact.email = text;
                    });
                  },
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
                TextField(
                    decoration: InputDecoration(labelText: "Phone"),
                    focusNode: _phoneFocus,
                    onChanged: (text) {
                      _userEdited = true;

                      setState(() {
                        _editedContact.phone = text;
                      });
                    },
                    keyboardType: TextInputType.phone,
                    controller: _phoneController),
              ],
            ),
          ),
        ));
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          //TODO: Componentizar essa função
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar Alterações?"),
              content: Text("Se sair, as alterações serão descartadas!"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Sim"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
