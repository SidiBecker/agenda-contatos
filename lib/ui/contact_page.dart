import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:agenda_contatos/helpers/util.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  ContactHelper helper = ContactHelper();

  bool _userEdited = false;
  Contact _editedContact;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  MaskedTextController _phoneController =
      MaskedTextController(mask: Util.PHONE_MASK);

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();

  bool _newContact = true;

  final _formKey = GlobalKey<FormState>();
  FocusNode _focusInvalid;

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _newContact = false;
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
            title: Text(_editedContact.name ?? "Novo Contato"),
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  //TODO: Salvar o objeto nesta página
                  _editedContact.phone =
                      _editedContact.phone.replaceAll(RegExp("[^0-9]"), "");

                  if (_newContact) {
                    await helper.saveContact(_editedContact);
                  } else {
                    await helper.updateContact(_editedContact);
                  }

                  Navigator.pop(context, _editedContact);
                } else {
                  FocusScope.of(context).requestFocus(_focusInvalid);
                  _focusInvalid = null;
                }
              },
              child: Icon(Icons.save)),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    //TODO: Componente
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
                Form(
                  key: _formKey,
                  child: Column(children: <Widget>[
                    // Add TextFormFields and RaisedButton here.
                    _buildTextField(
                        "Name",
                        _nameFocus,
                        "name",
                        TextInputType.text,
                        _nameController,
                        TextInputAction.next,
                        nextFocus: _emailFocus),
                    _buildTextField(
                        "Email",
                        _emailFocus,
                        "email",
                        TextInputType.emailAddress,
                        _emailController,
                        TextInputAction.next,
                        nextFocus: _phoneFocus),
                    _buildTextField(
                        "Phone",
                        _phoneFocus,
                        "phone",
                        TextInputType.phone,
                        _phoneController,
                        TextInputAction.done)
                  ]),
                ),
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

  bool fieldValidate(String valueField, FocusNode focus) {
    return !(valueField == null || valueField.isEmpty);
  }

  Widget _buildTextField(
      String label,
      FocusNode focusNode,
      String prop,
      TextInputType type,
      TextEditingController editingController,
      TextInputAction action,
      {FocusNode nextFocus}) {
    return TextFormField(
        decoration: InputDecoration(
          labelText: label,
        ),
        focusNode: focusNode,
        onChanged: (text) {
          _userEdited = true;

          setState(() {
            _editedContact.setProps = {prop: text};
          });
        },
        keyboardType: type,
        controller: editingController,
        textInputAction: action,
        validator: (value) {
          if (_userEdited && value.isEmpty) {
            if (_focusInvalid == null) {
              print(label);
              _focusInvalid = focusNode;
            }
            return 'O campo não pode ser vazio!';
          } else {
            return null;
          }
        },
        onFieldSubmitted: (value) {
          if (value.isNotEmpty) {
            if (action == TextInputAction.done) {
              //TODO: Enviar formulário
            } else {
              _fieldFocusChange(context, focusNode, nextFocus);
            }
          } else {
            //TODO: Validacao formulario
            _formKey.currentState.validate();
          }
        });
  }
}

_fieldFocusChange(
    BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}
