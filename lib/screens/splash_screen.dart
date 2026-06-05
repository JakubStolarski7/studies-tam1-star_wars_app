import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import 'characters_screen.dart';
import 'planets_screen.dart';
import 'starships_screen.dart';
import 'favorites_screen.dart';

enum IntroPhase { ready, blueText, logo, crawl, panDown }

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  IntroPhase _currentPhase = IntroPhase.ready;
  bool _blueTextVisible = false;
  bool _readyButtonVisible = true;
  bool _isSkipped = false;

  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  late AnimationController _crawlController;
  late Animation<double> _crawlPosition;

  late AnimationController _panDownController;
  late Animation<Offset> _menuSlide;
  late Animation<Offset> _crawlPanUp;

  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _volumeTimer;
  Timer? _fadeTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _logoController = AnimationController(duration: const Duration(seconds: 8), vsync: this);
    _logoScale = Tween<double>(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );
    _logoOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.7, 1.0)),
    );

    _crawlController = AnimationController(duration: const Duration(seconds: 45), vsync: this);
    _crawlPosition = Tween<double>(begin: 1.0, end: -2.5).animate(
      CurvedAnimation(parent: _crawlController, curve: Curves.linear),
    );

    _panDownController = AnimationController(duration: const Duration(seconds: 3), vsync: this);
    _menuSlide = Tween<Offset>(begin: const Offset(0, 1.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _panDownController, curve: Curves.easeInOutCubic),
    );
    _crawlPanUp = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1.5)).animate(
      CurvedAnimation(parent: _panDownController, curve: Curves.easeInOutCubic),
    );

    _logoController.addListener(() => setState(() {}));
    _panDownController.addListener(() => setState(() {}));
  }

  Future<void> _startExperience() async {
    setState(() {
      _readyButtonVisible = false;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _currentPhase = IntroPhase.blueText;
    });

    _startIntroSequence();
  }

  Future<void> _startIntroSequence() async {
    setState(() => _blueTextVisible = true);
    await Future.delayed(const Duration(seconds: 4));
    if (_isSkipped) return;

    setState(() => _blueTextVisible = false);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (_isSkipped) return;

    setState(() => _currentPhase = IntroPhase.logo);
    _logoController.forward();
    _setupAudio();

    await Future.delayed(const Duration(milliseconds: 6500));
    if(_isSkipped) return;

    setState(() => _currentPhase = IntroPhase.crawl);
    _crawlController.forward();

    await Future.delayed(const Duration(seconds: 35));
    if(_isSkipped) return;

    setState(() => _currentPhase = IntroPhase.panDown);
    _panDownController.forward();
  }

  Future<void> _setupAudio() async {
    await _audioPlayer.setVolume(1.0);
    await _audioPlayer.play(AssetSource('intro.mp3'));

    _volumeTimer = Timer(const Duration(seconds: 53), () {
      _fadeVolume(start: 1.0, end: 0.3, duration: const Duration(seconds: 3));
    });

    _audioPlayer.onPlayerComplete.listen((event) async {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(0.3);
      await _audioPlayer.play(AssetSource('loop.mp3'));
    });
  }

  void _fadeVolume({required double start, required double end, required Duration duration}) {
    const int steps = 20;
    final stepDuration = duration.inMilliseconds ~/ steps;
    final volumeStep = (start - end) / steps;
    double currentVolume = start;

    _fadeTimer = Timer.periodic(Duration(milliseconds: stepDuration), (timer) {
      currentVolume -= volumeStep;
      if (currentVolume <= end) {
        _audioPlayer.setVolume(end);
        timer.cancel();
      } else {
        _audioPlayer.setVolume(currentVolume);
      }
    });
  }

  Future<void> _skipIntro() async {
    _volumeTimer?.cancel();
    _fadeTimer?.cancel();
    _logoController.stop();
    _crawlController.stop();

    await _audioPlayer.stop();
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setVolume(0.3);
    await _audioPlayer.play(AssetSource('loop.mp3'));

    setState(() {
      _isSkipped = true;
      _currentPhase = IntroPhase.panDown;
    });
    _panDownController.value = 1.0;
  }

  @override
  void dispose() {
    _logoController.dispose();
    _crawlController.dispose();
    _panDownController.dispose();
    _audioPlayer.dispose();
    _volumeTimer?.cancel();
    _fadeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // TŁO
          if (_currentPhase != IntroPhase.blueText && _currentPhase != IntroPhase.ready)
            const Positioned.fill(child: StarBackground()),

          //EKRAN STARTOWY
          if (_currentPhase == IntroPhase.ready)
            Center(
              child: AnimatedOpacity(
                opacity: _readyButtonVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                child: ElevatedButton(
                  onPressed: _readyButtonVisible ? _startExperience : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE81F),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  ),
                  child: const Text("ROZPOCZNIJ", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              ),
            ),

          //NIEBIESKI TEKST
          if (_currentPhase == IntroPhase.blueText)
            Center(
              child: AnimatedOpacity(
                opacity: _blueTextVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 1500),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("A long time ago in a galaxy far,", style: TextStyle(color: Color(0xFF4EE2EC), fontSize: 24)),
                    Text("far away....", style: TextStyle(color: Color(0xFF4EE2EC), fontSize: 24)),
                  ],
                ),
              ),
            ),

          //LOGO
          if (!_isSkipped && (_currentPhase == IntroPhase.logo || _currentPhase == IntroPhase.crawl || _currentPhase == IntroPhase.panDown))
            Center(
              child: Opacity(
                opacity: _logoOpacity.value,
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: SvgPicture.asset('assets/Star_Wars_Yellow_Logo.svg', width: 300),
                ),
              ),
            ),

          //NAPISY
          if (!_isSkipped && (_currentPhase == IntroPhase.crawl || _currentPhase == IntroPhase.panDown))
            Positioned.fill(
              child: SlideTransition(
                position: _crawlPanUp,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) => const LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.white, Colors.white], stops: [0.0, 0.15, 1.0],
                  ).createShader(bounds),
                  blendMode: BlendMode.dstIn,
                  child: Transform(
                    transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(-0.55),
                    alignment: FractionalOffset.bottomCenter,
                    child: AnimatedBuilder(
                      animation: _crawlController,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, MediaQuery.of(context).size.height * _crawlPosition.value),
                        child: child,
                      ),
                      child: OverflowBox(
                        maxHeight: double.infinity,
                        alignment: Alignment.topCenter,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            "EPIZOD X\n\nNadszedł czas na ostateczne\nzaliczenie przedmiotu.\n\nGalaktyka jest w rozsypce, a\npotężne API SWAPI ukrywa w\nsobie kluczowe dane o\nrebeliantach i imperium.\n\nMłody programista musi użyć\npotęgi Fluttera, aby stworzyć\nniezawodny system danych.\n\nJeśli mu się uda, zyska\nupragnioną ocenę i przywróci\nporządek w systemie USOS.\n\nNiech kod będzie z Tobą!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFFFFE81F), fontSize: 44, fontWeight: FontWeight.w900, letterSpacing: 2.0, height: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          //GŁÓWNY WIDOK APLIKACJI
          if (_currentPhase == IntroPhase.panDown)
            SlideTransition(
              position: _menuSlide,
              child: const MainDashboard(),
            ),

          if (_currentPhase != IntroPhase.panDown && _currentPhase != IntroPhase.ready)
            Positioned(
              bottom: 30, right: 20,
              child: TextButton(
                onPressed: _skipIntro,
                child: const Text("Pomiń", style: TextStyle(color: Colors.white54, fontSize: 16)),
              ),
            ),
        ],
      ),
    );
  }
}

class StarBackground extends StatelessWidget {
  const StarBackground({super.key});
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _StarPainter());
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = Random(42);
    for (int i = 0; i < 250; i++) {
      paint.color = Colors.white.withOpacity(random.nextDouble() * 0.8 + 0.2);
      canvas.drawCircle(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height), random.nextDouble() * 1.5, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// GŁÓWNY WIDOK APLIKACJI
class MainDashboard extends StatelessWidget {
  const MainDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = MediaQuery.of(context).size.width > 800 ? 2 : 1;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("DATAPAD REBELII", style: TextStyle(color: Color(0xFF4EE2EC), fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
                children: [
                  _buildHudCard("Baza Postaci", "Jedi, Sithowie, Łowcy Nagród", 'https://images.unsplash.com/photo-1655983547113-ebd215417da9?w=1000&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8ZGFydGglMjB2YWRlcnxlbnwwfHwwfHx8MA%3D%3D', Colors.redAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CharactersScreen()))),
                  _buildHudCard("Flota Gwiezdna", "Myśliwce i Krążowniki", 'https://images.unsplash.com/photo-1631282715105-5180652e52c1?w=1000&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTV8fHN0YXIlMjB3YXJzJTIwc2hpcHxlbnwwfHwwfHx8MA%3D%3D', Colors.blueAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StarshipsScreen()))),
                  _buildHudCard("Atlas Planet", "Systemy Zewnętrznych Rubieży", 'https://images.unsplash.com/photo-1762441112136-4dfc6edf58e8?w=1000&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8c3RhciUyMHdhcnMlMjBwbGFuZXR8ZW58MHx8MHx8fDA%3D', const Color(0xFFFFE81F), () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PlanetsScreen()))),
                  _buildHudCard("Tajne Archiwa", "Zapisane dane offline", 'https://images.unsplash.com/photo-1623476408624-721c9185d569?w=1000&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8c3RhciUyMHdhcnMlMjBwbGFuZXR8ZW58MHx8MHx8fDA%3D', Colors.greenAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHudCard(String title, String subtitle, String imageUrl, Color glowColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: glowColor.withOpacity(0.5), width: 1.5),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
          ),
        ),

        child: Stack(
          children: [
            Positioned(
              bottom: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 15,
              right: 15,
              child: Icon(Icons.arrow_forward_ios, color: glowColor, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
