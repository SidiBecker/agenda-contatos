import 'package:agenda_contatos/ui/home_page.dart';
import 'package:flutter/material.dart';

//NAO USA ISSO, PELO AMOR DE DEUS: const COLOR_PRIMARY = Colors.deepPurple;

void main() {
  runApp(MaterialApp(
    home: HomePage(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primarySwatch: Colors.deepPurple),
  ));
}
