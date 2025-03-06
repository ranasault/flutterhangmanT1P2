import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => HangmanProvider(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HangmanGame(),
    );
  }
}

class HangmanProvider extends ChangeNotifier {
  final List<String> words = ["FLUTTER", "DART", "MOBILE", "WIDGET", "STATE"];
  late String selectedWord;
  late Set<String> guessedLetters;
  int wrongGuesses = 0;
  bool gameOver = false;
  bool gameWon = false;

  HangmanProvider() {
    _startNewGame();
  }

  void _startNewGame() {
    final random = Random();
    selectedWord = words[random.nextInt(words.length)];
    guessedLetters = {};
    wrongGuesses = 0;
    gameOver = false;
    gameWon = false;
    notifyListeners();
  }

  void guessLetter(String letter) {
    if (gameOver || guessedLetters.contains(letter)) return;

    guessedLetters.add(letter);
    if (!selectedWord.contains(letter)) {
      wrongGuesses++;
    }
    _checkGameStatus();
    notifyListeners();
  }

  void _checkGameStatus() {
    if (wrongGuesses >= 6) {
      gameOver = true;
    } else if (selectedWord.split('').every((l) => guessedLetters.contains(l))) {
      gameWon = true;
      gameOver = true;
    }
  }

  void resetGame() {
    _startNewGame();
  }
}

class HangmanGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hangman = Provider.of<HangmanProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text("Flutter Hangman")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Wrong guesses left: ${6 - hangman.wrongGuesses}",
              style: TextStyle(fontSize: 20)),
          SizedBox(height: 20),
          Text(_buildWordDisplay(hangman),
              style: TextStyle(fontSize: 30, letterSpacing: 4)),
          SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _buildLetterButtons(hangman),
          ),
          SizedBox(height: 20),
          if (hangman.gameOver) ...[
            Text(
              hangman.gameWon ? "You WON! 🎉" : "You LOST! 😢",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: hangman.resetGame,
              child: Text("Play Again"),
            ),
          ]
        ],
      ),
    );
  }

  String _buildWordDisplay(HangmanProvider hangman) {
    return hangman.selectedWord.split('').map((letter) {
      return hangman.guessedLetters.contains(letter) ? letter : '_';
    }).join(' ');
  }

  List<Widget> _buildLetterButtons(HangmanProvider hangman) {
    return "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        .split('')
        .map((letter) => ElevatedButton(
      onPressed: hangman.guessedLetters.contains(letter)
          ? null
          : () => hangman.guessLetter(letter),
      child: Text(letter),
    ))
        .toList();
    }
}