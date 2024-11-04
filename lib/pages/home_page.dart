import 'package:flutter/material.dart';
import 'package:irregular_verbs_app/pages/game_page.dart';
import 'package:irregular_verbs_app/pages/verb_list.dart';
import 'package:irregular_verbs_app/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();

  void openVerbBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController verbController = TextEditingController();
        TextEditingController infinitiveController = TextEditingController();
        TextEditingController pastController = TextEditingController();
        TextEditingController participleController = TextEditingController();

        return AlertDialog(
          title: Text(docID == null ? 'Añadir Verbo' : 'Editar Verbo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: verbController,
                  decoration: InputDecoration(labelText: 'Verbo'),
                ),
                TextField(
                  controller: infinitiveController,
                  decoration: InputDecoration(labelText: 'Infinitivo'),
                ),
                TextField(
                  controller: pastController,
                  decoration: InputDecoration(labelText: 'Pasado'),
                ),
                TextField(
                  controller: participleController,
                  decoration: InputDecoration(labelText: 'Participio'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                String verb = verbController.text;
                String infinitivo = infinitiveController.text;
                String pasado = pastController.text;
                String participio = participleController.text;

                if (docID == null) {
                  firestoreService.addVerb(verb, infinitivo, pasado, participio);
                } else {
                  firestoreService.updateVerb(docID, verb, infinitivo, pasado, participio);
                }

                verbController.clear();
                infinitiveController.clear();
                pastController.clear();
                participleController.clear();

                Navigator.of(context).pop();
              },
              child: Text(docID == null ? 'Añadir' : 'Actualizar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verbos irregulares'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list), text: 'Lista de Verbos'),
              Tab(icon: Icon(Icons.play_circle_fill_rounded), text: 'Jugar'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: openVerbBox,
          child: const Icon(Icons.add),
        
        ),
        body: TabBarView(
          children: [
            // Usa el widget VerbList y pasa firestoreService
            VerbList(firestoreService: firestoreService),
            const Center(
              child: GamePage(),
            ),
          ],
        ),
      ),
    );
  }
}
