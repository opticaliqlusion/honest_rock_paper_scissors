import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:collection';
import 'package:crypto/crypto.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rock Paper Scissors',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Rock Paper Scissors Game'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Random _random = Random();
  String _result = 'Game ready! Commitment hash generated.';
  String _computerChoice = '';
  String _computerChoice_emoji = '';
  String _playerChoice = '';
  String _currentSalt = '';
  String _currentCommitment = '';
  int _playerScore = 0;
  int _computerScore = 0;
  int _ties = 0;
  bool _revealPhase = false;
  
  // Queue to store last 20 game results
  final Queue<String> _gameHistory = Queue<String>();
  static const int _maxHistoryLength = 20;

  @override
  void initState() {
    super.initState();
    _generateNewCommitment();
  }

  String _generateSalt() {
    final values = List<int>.generate(16, (i) => _random.nextInt(256));
    return base64Url.encode(values);
  }

  String _calculateHash(String choice, String salt) {
    final bytes = utf8.encode(choice + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _generateNewCommitment() {
    final choices = ['Rock', 'Paper', 'Scissors'];
    final choices_emoji = ['🪨', '📄', '✂️'];

    int intmod3 = _random.nextInt(3);
    _computerChoice = choices[intmod3];
    _computerChoice_emoji = choices_emoji[intmod3];
    _currentSalt = _generateSalt();
    _currentCommitment = _calculateHash(_computerChoice, _currentSalt);
    _revealPhase = false;
    _playerChoice = '';
  }

  void _addToHistory(String winner) {
    if (_gameHistory.length >= _maxHistoryLength) {
      _gameHistory.removeFirst();
    }
    _gameHistory.add(winner);
  }

  void _playGame(String playerChoice) {
    setState(() {
      _playerChoice = playerChoice;
      _revealPhase = true;

      // Determine the winner
      if (_playerChoice == _computerChoice) {
        _result = "It's a tie!";
        _ties++;
        _addToHistory('tie');
      } else if ((_playerChoice == 'Rock' && _computerChoice == 'Scissors') ||
          (_playerChoice == 'Paper' && _computerChoice == 'Rock') ||
          (_playerChoice == 'Scissors' && _computerChoice == 'Paper')) {
        _result = 'You win!';
        _playerScore++;
        _addToHistory('player');
      } else {
        _result = 'Computer wins!';
        _computerScore++;
        _addToHistory('computer');
      }
    });
  }

  Widget _buildExplanationCard() {
    return Card(
      elevation: 4,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerTheme: const DividerThemeData(
            space: 40,
          ),
        ),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: const Row(
            children: [
              Text('🎮 How This Fair Play System Works', 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
              ),
              SizedBox(width: 10),
              Chip(
                label: Text('Provably Fair'),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildExplanationStep(
                    '1️⃣',
                    'Computer Makes Choice',
                    'The computer picks Rock, Paper, or Scissors before you do.'
                  ),
                  _buildExplanationStep(
                    '2️⃣',
                    'Commitment Created',
                    'The choice is combined with a random "salt" value and converted into a commitment hash. Think of it like the computer putting its choice in a sealed envelope!'
                  ),
                  _buildExplanationStep(
                    '3️⃣',
                    'Your Turn',
                    'You make your choice while seeing the commitment hash. The computer can\'t change its choice now!'
                  ),
                  _buildExplanationStep(
                    '4️⃣',
                    'Verification',
                    'The computer reveals its original choice and salt. You can verify the game was fair by checking that the original commitment matches the revealed values.'
                  ),
                  const Divider(),
                  const Text(
                    '🔍 Why This Matters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'This system ensures the computer can\'t cheat by changing its choice after seeing yours. '
                    'It\'s like Rock Paper Scissors in real life, where both players show their hands at the same time! '
                    'The cryptographic commitment scheme makes this digitally possible.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationStep(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationInfo() {
    if (!_revealPhase) {
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Commitment Hash:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SelectableText(
                _currentCommitment,
                style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 10),
              const Text(
                'This hash proves the computer has already made its choice.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    } else {
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Verification Details:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('Computer\'s choice: $_computerChoice $_computerChoice_emoji'),
              const SizedBox(height: 5),
              SelectableText('Salt: $_currentSalt'),
              const SizedBox(height: 5),
              SelectableText('Original commitment: $_currentCommitment'),
              const SizedBox(height: 5),
              SelectableText(
                'Verification hash: ${_calculateHash(_computerChoice, _currentSalt)}',
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _generateNewCommitment();
                  });
                },
                child: const Text('Start Next Round'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildScoreCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text('👤 You', style: TextStyle(fontSize: 20)),
                Text(
                  _playerScore.toString(),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Column(
              children: [
                const Text('🤝 Ties', style: TextStyle(fontSize: 20)),
                Text(
                  _ties.toString(),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Column(
              children: [
                const Text('🤖 Computer', style: TextStyle(fontSize: 20)),
                Text(
                  _computerScore.toString(),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameHistory() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Last 20 Games History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: _gameHistory.map((result) {
                String emoji;
                Color backgroundColor;
                switch (result) {
                  case 'player':
                    emoji = '👤';
                    backgroundColor = Colors.green.withOpacity(0.2);
                    break;
                  case 'computer':
                    emoji = '🤖';
                    backgroundColor = Colors.red.withOpacity(0.2);
                    break;
                  default:
                    emoji = '🤝';
                    backgroundColor = Colors.grey.withOpacity(0.2);
                }
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButton(String choice, String emoji) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        onPressed: _revealPhase ? null : () => _playGame(choice),
        child: Text(
          '$emoji $choice',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _playerScore = 0;
                _computerScore = 0;
                _ties = 0;
                _gameHistory.clear();
                _generateNewCommitment();
              });
            },
            tooltip: 'Reset Game',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildExplanationCard(), // Add the explanation at the top
              const SizedBox(height: 20),
              _buildScoreCard(),
              const SizedBox(height: 20),
              _buildGameHistory(),
              const SizedBox(height: 20),
              _buildVerificationInfo(),
              const SizedBox(height: 30),
              const Text(
                'Make your choice:',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildChoiceButton('Rock', '🪨'),
                  _buildChoiceButton('Paper', '📄'),
                  _buildChoiceButton('Scissors', '✂️'),
                ],
              ),
              const SizedBox(height: 30),
              if (_revealPhase) ...[
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Your choice: $_playerChoice',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Computer\'s choice: $_computerChoice',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _result,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}