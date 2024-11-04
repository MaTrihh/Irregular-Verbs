import 'package:flutter/material.dart';
import 'package:irregular_verbs_app/pages/play_game_page.dart';

class GamePage extends StatelessWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juego de Verbos'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PlayVerbGame(),
              ),
            );
          },
          child: const Text('Jugar'),
        ),
      ),
    );
  }
}
