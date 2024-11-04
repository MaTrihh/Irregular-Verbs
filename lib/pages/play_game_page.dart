import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:irregular_verbs_app/services/firestore.dart';

class PlayVerbGame extends StatefulWidget {
  const PlayVerbGame({Key? key}) : super(key: key);

  @override
  _PlayVerbGameState createState() => _PlayVerbGameState();
}

class _PlayVerbGameState extends State<PlayVerbGame> {
  final FirestoreService firestoreService = FirestoreService();
  List<DocumentSnapshot> verbosList = [];
  List<String> aciertos = [];
  List<String> fallos = [];
  int currentIndex = 0;
  bool isLoading = true;

  TextEditingController infinitivoController = TextEditingController();
  TextEditingController pasadoController = TextEditingController();
  TextEditingController participioController = TextEditingController();

  FocusNode infinitivoFocusNode = FocusNode();
  FocusNode pasadoFocusNode = FocusNode();
  FocusNode participioFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    fetchVerbs();
  }

  @override
  void dispose() {
    infinitivoController.dispose();
    pasadoController.dispose();
    participioController.dispose();
    infinitivoFocusNode.dispose();
    pasadoFocusNode.dispose();
    participioFocusNode.dispose();
    super.dispose();
  }

  // Obtener verbos de Firebase y mezclarlos aleatoriamente
  void fetchVerbs() async {
    QuerySnapshot snapshot = await firestoreService.getVerbsStream().first;
    setState(() {
      verbosList = snapshot.docs;
      verbosList.shuffle(); // Mezcla los verbos aleatoriamente
      isLoading = false;
    });
  }

  // Comprobar si los campos son correctos
  void checkAnswers() {
    var data = verbosList[currentIndex].data() as Map<String, dynamic>;
    String correctInfinitivo = data['infinitivo'];
    String correctPasado = data['pasado'];
    String correctParticipio = data['participio'];

    String userInfinitivo = infinitivoController.text.trim();
    String userPasado = pasadoController.text.trim();
    String userParticipio = participioController.text.trim();

    if (userInfinitivo == correctInfinitivo &&
        userPasado == correctPasado &&
        userParticipio == correctParticipio) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Correcto!')),
      );
      aciertos.add(data['verb']); // Añadir verbo a la lista de aciertos
    } else {
      var data = verbosList[currentIndex].data() as Map<String, dynamic>;
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Error!! Solución: ${data['infinitivo']} / ${data['pasado']} / ${data['participio']}'),
      ),
    );
      fallos.add(data['verb']); // Añadir verbo a la lista de fallos
    }
    goToNextVerb();
  }

  // Función para mostrar la solución
  void showSolution() {
    var data = verbosList[currentIndex].data() as Map<String, dynamic>;
    fallos.add(data['verb']); // Añadir a fallos si el usuario pidió la solución
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Solución: ${data['infinitivo']} / ${data['pasado']} / ${data['participio']}'),
      ),
    );
    goToNextVerb();
  }

  // Ir al siguiente verbo o cerrar la página si no quedan más verbos
  void goToNextVerb() {
    setState(() {
      if (currentIndex < verbosList.length - 1) {
        currentIndex++;
      } else {
        showSummaryDialog(); // Mostrar resumen al final del juego
      }
      infinitivoController.clear();
      pasadoController.clear();
      participioController.clear();
    });
    FocusScope.of(context).requestFocus(infinitivoFocusNode); // Volver el foco al infinitivo
  }

  // Mostrar resumen al final del juego
  void showSummaryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resultados del Juego'),
          content: SizedBox(
            height: 300,  // Definimos un tamaño fijo para evitar el problema
            child: Column(
              children: [
                Text('Aciertos: ${aciertos.length}'),
                const SizedBox(height: 8),
                Text('Fallos: ${fallos.length}'),
                const SizedBox(height: 16),
                const Text('Verbos fallados:'),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: fallos.map((verbo) => Text(verbo)).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
                Navigator.of(context).pop(); // Volver a la página anterior
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Obtener el verbo actual
    var currentVerbData = verbosList[currentIndex].data() as Map<String, dynamic>;
    String meaning = currentVerbData['verb'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Juego de Verbos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Indicador de progreso y contadores
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progreso: ${currentIndex + 1}/${verbosList.length}',
                    style: const TextStyle(fontSize: 16)),
                Text('Aciertos: ${aciertos.length}',
                    style: const TextStyle(fontSize: 16)),
                Text('Fallos: ${fallos.length}',
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 20),
            // Mostrar el significado en el centro superior, con estilo
            Expanded(
              child: Center(
                child: Text(
                  meaning,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Inputs text alineados verticalmente
            TextField(
              controller: infinitivoController,
              focusNode: infinitivoFocusNode,
              decoration: const InputDecoration(
                labelText: 'Infinitivo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pasadoController,
              focusNode: pasadoFocusNode,
              decoration: const InputDecoration(
                labelText: 'Pasado',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: participioController,
              focusNode: participioFocusNode,
              decoration: const InputDecoration(
                labelText: 'Participio',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            // Botón de comprobar
            ElevatedButton(
              onPressed: checkAnswers,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text(
                'Comprobar',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            // Botón de solución
            ElevatedButton(
              onPressed: showSolution,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16), backgroundColor: Colors.red,
              ),
              child: const Text(
                'Solución',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
