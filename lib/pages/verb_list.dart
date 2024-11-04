import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:irregular_verbs_app/services/firestore.dart';

class VerbList extends StatelessWidget {
  final FirestoreService firestoreService;

  const VerbList({Key? key, required this.firestoreService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getVerbsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List verbsList = snapshot.data!.docs;
          return ListView.builder(
            itemCount: verbsList.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = verbsList[index];
              String docID = document.id;

              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              String verbText = data['verb'];
              String infinitivoText = data['infinitivo'];
              String pasadoText = data['pasado'];
              String participioText = data['participio'];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verbo: $verbText',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Infinitivo: $infinitivoText',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Pasado: $pasadoText',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Participio: $participioText',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {
                                // Abrir el cuadro de diálogo para editar
                                openEditDialog(context, docID, verbText, infinitivoText, pasadoText, participioText);
                              },
                              icon: const Icon(Icons.settings, color: Colors.blue),
                            ),
                            IconButton(
                              onPressed: () {
                                // Eliminar el verbo
                                firestoreService.deleteVerb(docID);
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(
            child: Text('No hay verbos...'),
          );
        }
      },
    );
  }

  // Función para abrir el cuadro de diálogo para editar
  void openEditDialog(BuildContext context, String docID, String verbText, String infinitivoText, String pasadoText, String participioText) {
    TextEditingController verbController = TextEditingController(text: verbText);
    TextEditingController infinitivoController = TextEditingController(text: infinitivoText);
    TextEditingController pasadoController = TextEditingController(text: pasadoText);
    TextEditingController participioController = TextEditingController(text: participioText);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Verbo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: verbController,
                  decoration: const InputDecoration(labelText: 'Verbo'),
                ),
                TextField(
                  controller: infinitivoController,
                  decoration: const InputDecoration(labelText: 'Infinitivo'),
                ),
                TextField(
                  controller: pasadoController,
                  decoration: const InputDecoration(labelText: 'Pasado'),
                ),
                TextField(
                  controller: participioController,
                  decoration: const InputDecoration(labelText: 'Participio'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Actualizar el verbo con los valores ingresados
                firestoreService.updateVerb(
                  docID,
                  verbController.text,
                  infinitivoController.text,
                  pasadoController.text,
                  participioController.text,
                );

                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: const Text('Guardar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}