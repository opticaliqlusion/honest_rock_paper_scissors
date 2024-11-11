import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:collection';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:ui_web' as ui_web;
import 'package:flutter/foundation.dart' show kIsWeb;



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


// Add the new GameTimelineWidget class
class GameTimelineWidget extends StatelessWidget {
  final List<GameRound> gameHistory;
  
  const GameTimelineWidget({super.key, required this.gameHistory});


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row for player label
        const Row(
          children: [
            SizedBox(width: 8),  // Align with the timeline content
            Text(
              '👤 Player',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        Container(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            reverse: false,  // Most recent games appear on the right
            itemCount: gameHistory.length,
            itemBuilder: (context, index) {
              final game = gameHistory[index];
              return Container(
                width: 80,
                child: Column(
                  children: [
                    // Player's choice (top)
                    Container(
                      height: 40,
                      child: Center(
                        child: Text(
                          _getChoiceEmoji(game.playerChoice),
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    // Timeline part (middle)
                    Container(
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Timeline line
                          Container(
                            height: 2,
                            color: Colors.grey.shade300,
                          ),
                          // Timeline dot and result
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _getResultColor(game.result),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _getResultEmoji(game.result),
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Computer's choice (bottom)
                    Container(
                      height: 40,
                      child: Center(
                        child: Text(
                          _getChoiceEmoji(game.computerChoice),
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Row for computer label
        const Row(
          children: [
            SizedBox(width: 8),  // Align with the timeline content
            Text(
              '🤖 Computer',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }


  String _getChoiceEmoji(String choice) {
    switch (choice) {
      case 'Rock': return '🪨';
      case 'Paper': return '📄';
      case 'Scissors': return '✂️';
      default: return '';
    }
  }

  String _getResultEmoji(String result) {
    switch (result) {
      case 'player': return '🎉';
      case 'computer': return '🤖';
      case 'tie': return '🤝';
      default: return '';
    }
  }

  Color _getResultColor(String result) {
    switch (result) {
      case 'player':
        return Colors.green.withOpacity(0.2);
      case 'computer':
        return Colors.red.withOpacity(0.2);
      case 'tie':
        return Colors.grey.withOpacity(0.2);
      default:
        return Colors.transparent;
    }
  }
}


// Add a class to store game round information
class GameRound {
  final String playerChoice;
  final String computerChoice;
  final String result;

  GameRound({
    required this.playerChoice,
    required this.computerChoice,
    required this.result,
  });
}
String getBasePath() {
  if (kIsWeb) {
    final currentUrl = html.window.location.href;
    if (currentUrl.contains('github.io')) {
      return '/honest_rock_paper_scissors'; // Your repository name
    }
  }
  return '';
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
    // Modified to store full game rounds instead of just results
  final List<GameRound> _gameHistory = [];
  static const int _maxHistoryLength = 20;

  void _showExplanationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.amber, size: 28),
                    SizedBox(width: 12),
                    Text(
                      "Why This App Exists",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "This isn't just another Rock Paper Scissors game - it's a demonstration of how we can make digital games provably fair.",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                const Text(
                  "In traditional online games, you have to trust that the computer isn't cheating by waiting to see your choice before making its own. This app solves that problem using math!",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                const Text(
                  "By showing you a commitment hash before you make your choice, and then revealing the proof afterward, we can mathematically guarantee that the computer made its choice before you did - just like in a real-world game!",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Got it!"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void _addToHistory(String winner) {
    if (_gameHistory.length >= _maxHistoryLength) {
      _gameHistory.removeAt(0);
    }
    _gameHistory.add(GameRound(
      playerChoice: _playerChoice,
      computerChoice: _computerChoice,
      result: winner,
    ));
  }

  @override
  void initState() {
    super.initState();
    _generateNewCommitment();

    // Register the iframe view factory
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'verification-console-iframe',  // Use a unique name
      (int viewId) {
        final basepath = getBasePath();
        final consoleUrl = Uri(
          path: '$basepath/console.html',
          queryParameters: {
            'choice': _computerChoice,
            'salt': _currentSalt,
          },
        ).toString();
        
        return html.IFrameElement()
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..src = consoleUrl;
      },
    );

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


  Widget _buildHashDisplay(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.key, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            value,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildChoiceDisplay(
    String label, 
    String value, 
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationInfo() {
    return Column(
      children: [
        // Always show the commitment hash card
        Card(
          elevation: 4,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.white,
                ],
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.lock_outline, color: Colors.blue.shade700),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Commitment Hash',
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                          'Computer\'s sealed choice',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildHashDisplay('COMMITMENT', _currentCommitment),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, 
                        size: 20, 
                        color: Colors.blue.shade700
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'This hash proves the computer has already made its choice',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Show verification details only in reveal phase
        if (_revealPhase) ...[
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.shade50,
                    Colors.white,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.verified_outlined, 
                          color: Colors.purple.shade700
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verification Details',
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          Text(
                            'Proof of fair play',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade100,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildChoiceDisplay(
                              'Computer\'s Choice',
                              '$_computerChoice $_computerChoice_emoji',
                              Icons.computer,
                              Colors.blue.shade100,
                              Colors.blue.shade700,
                            ),
                            const SizedBox(width: 16),
                            _buildHashDisplay('Secret Salt', _currentSalt),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const HtmlElementView(
                            viewType: 'verification-console-iframe',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _generateNewCommitment();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Start Next Round'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
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

  
  Widget _buildChoiceSection() {
    if (_revealPhase) {
      return const SizedBox.shrink(); // Returns an empty widget during reveal phase
    }
    
    return Column(
      children: [
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
      ],
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
      
      floatingActionButton: FloatingActionButton(
        onPressed: _showExplanationDialog,
        child: const Icon(Icons.question_mark),
        tooltip: 'But Why, Though?',
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
              if (_gameHistory.isNotEmpty) ...[
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Game History',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        GameTimelineWidget(gameHistory: _gameHistory),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              const SizedBox(height: 20),
              _buildVerificationInfo(),
              const SizedBox(height: 30),
              _buildChoiceSection(), // Replace the direct choice buttons with this method
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