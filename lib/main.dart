import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import '../0-Tela_Inicial/tela_inicial.dart';
import '../1-H15/tela_h15.dart';
import '../4-Arquitetura/arquiteturaOUT.dart';
import 'tela_mapa_exploracao.dart';
import 'tela_mapa_biblioteca.dart';
import '../5-Manacas/entradaManacas.dart';
import '3-Praca/pracaalimentacao.dart';
import '../2-Biblioteca/biblioteca_fachada.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arquivo Capivara',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue[900],
        fontFamily: 'monospace',
      ),
      home: TelaInicial(),
      routes: {
        '/h15': (context) => TelaH15(),
        '/mapa': (context) => TelaMapaExploracao(),
        // Mapa/geolocalização específico para acessar a biblioteca.
        // Rota chamada depois do H15/Pingo para abrir o mapa da biblioteca.
        '/mapa_biblioteca': (context) => const TelaMapaBiblioteca(),
        '/h12': (context) => TelaArquiteturaOUT(),
        // Primeira cena interna da biblioteca, aberta após clicar na Corujita no mapa.
        // Rota chamada quando o jogador finalmente entra no ambiente da biblioteca.
        '/biblioteca': (context) => BibliotecaFachadaScreen(),
        '/refeitorio': (context) => Telapracaalimentacao(),
        '/manacas': (context) => EntradaManacasScreen(),
      },
    );
  }
}