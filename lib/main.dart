import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const GameScreen(),
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Game constants
  static const double gravity = -9.8;
  static const double birdSize = 60.0;
  static const double velocity = 2.5;
  
  // Game variables
  double birdY = 0;
  double initialPos = 0;
  double height = 0;
  double time = 0;
  int score = 0;
  bool gameHasStarted = false;
  
  // Animation controllers
  late AnimationController _birdController;
  late AnimationController _cloudController;
  
  @override
  void initState() {
    super.initState();
    _birdController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _cloudController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  void startGame() {
    setState(() {
      gameHasStarted = true;
      time = 0;
      score = 0;
      birdY = 0;
      initialPos = birdY;
    });
    
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      double newHeight = gravity * time * time + velocity * time;
      
      setState(() {
        time += 0.016;
        height = newHeight;
        birdY = initialPos - height;
        score = (time * 5).round();
      });
      
      if (birdIsDead()) {
        timer.cancel();
        _showGameOverDialog();
      }
    });
  }

  void jump() {
    setState(() {
      time = 0;
      initialPos = birdY;
      _birdController.forward(from: 0.0);
    });
  }

  bool birdIsDead() {
    return birdY < -0.95 || birdY > 0.95;
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: [
              const Icon(Icons.star, size: 50, color: Color(0xFF6C63FF)),
              const Text('Game Over', 
                style: TextStyle(color: Color(0xFF3F3D56), fontSize: 24)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Score: ${score.toInt()}',
                style: const TextStyle(
                  fontSize: 40,
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.bold,
                )),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    gameHasStarted = false;
                    birdY = 0;
                    score = 0;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text('Play Again', style: TextStyle(fontSize: 18,color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: gameHasStarted ? jump : startGame,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE8E8FF), Color(0xFFFFFFFF)],
            ),
          ),
          child: Stack(
            children: [
              // Animated clouds
              AnimatedBuilder(
                animation: _cloudController,
                builder: (context, child) {
                  return Positioned(
                    top: MediaQuery.of(context).size.height * 0.2,
                    left: _cloudController.value * MediaQuery.of(context).size.width,
                    child: SvgPicture.asset(
                      'assets/images/clouds.svg',
                      width: 100,
                    ),
                  );
                },
              ),
              
              // Bird
              AnimatedBuilder(
                animation: _birdController,
                builder: (context, child) {
                  return Container(
                    alignment: Alignment(0, birdY),
                    child: Transform.rotate(
                      angle: _birdController.value * 0.5,
                      child: SvgPicture.asset(
                        'assets/images/bird.svg',
                        width: birdSize,
                      ),
                    ),
                  );
                },
              ),
              
              // Ground
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SvgPicture.asset(
                  'assets/images/ground.svg',
                  fit: BoxFit.fill,
                ),
              ),
              
              // Score
              if (gameHasStarted)
                Positioned(
                  top: 50,
                  left: 20,
                  child: Text(
                    'Score: ${score.toInt()}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F3D56),
                    ),
                  ),
                ),
              
              // Start game message
              if (!gameHasStarted)
                Center(
                  child: Text(
                    'TAP TO START',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3F3D56).withOpacity(0.8),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _birdController.dispose();
    _cloudController.dispose();
    super.dispose();
  }
}
