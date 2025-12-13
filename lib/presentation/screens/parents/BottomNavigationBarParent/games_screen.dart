import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Game {
  final String title;
  final String imageUrl;
  final String url;
  final Color color1;
  final Color color2;

  const Game({
    required this.title,
    required this.imageUrl,
    required this.url,
    required this.color1,
    required this.color2,
  });
}

class KidsGamesScreen extends StatelessWidget {
  const KidsGamesScreen({super.key});

  static const List<Game> games = [
    Game(
      title: '✏️ Learn Number Writing',
      imageUrl:
          'https://img.freepik.com/free-vector/children-learning-numbers_1308-32260.jpg',
      url: 'https://www.autistichub.com/play/numberwriting/',
      color1: Color(0xFF3789C3),
      color2: Color(0xFF3789C3),
    ),
    Game(
      title: '🌙 Shadow Matching Game',
      imageUrl:
          'https://img.freepik.com/free-vector/animal-shadow-matching-activity_1308-112756.jpg',
      url: 'https://www.autistichub.com/play/shadowmatching/',
      color1: Color(0xFF4BA8A0),
      color2: Color(0xFF80D8C4),
    ),
    Game(
      title: '🔤 Find the Missing Letter',
      imageUrl:
          'https://img.freepik.com/free-vector/letter-matching-game-kids_1308-107435.jpg',
      url: 'https://www.autistichub.com/play/findmissingletter/',
      color1: Color(0xFFFFA726),
      color2: Color(0xFFFFD54F),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Games',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Color(0xFF3789C3),
                    ),
                  ),
                  Icon(
                    CupertinoIcons.game_controller_solid,
                    color: Color(0xFF3789C3),
                    size: 32,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 500 + (index * 200)),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 50),
                        child: child,
                      ),
                    ),
                    child: GameCard(game: game),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final Game game;
  const GameCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GameWebViewScreen(url: game.url, title: game.title),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [game.color1, game.color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: game.color1.withOpacity(0.3),
              offset: const Offset(0, 8),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              child: Image.network(
                game.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      game.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameWebViewScreen extends StatefulWidget {
  final String url;
  final String title;
  const GameWebViewScreen({super.key, required this.url, required this.title});

  @override
  State<GameWebViewScreen> createState() => _GameWebViewScreenState();
}

class _GameWebViewScreenState extends State<GameWebViewScreen> {
  late final WebViewController controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF3789C3),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7043)),
              ),
            ),
        ],
      ),
    );
  }
}
