import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../services/card_service.dart';
import '../services/prediction_service.dart';
import '../widgets/tarot_card.dart';

class CardReadingScreen extends StatefulWidget {
  const CardReadingScreen({super.key});

  @override
  State<CardReadingScreen> createState() => _CardReadingScreenState();
}

class _CardReadingScreenState extends State<CardReadingScreen>
    with TickerProviderStateMixin {
  final CardService _cardService = CardService();
  final PredictionService _predictionService = PredictionService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _glitchTimer;
  final Random _random = Random();

  List<String> _selectedCards = [];
  String _prediction = '';
  bool _showDeck = true;
  bool _isShuffling = false;
  bool _cardsRevealed = false;
  bool _showPrediction = false;
  bool _isScaryMode = false;
  
  // Glitch offsets
  double _glitchX = 0;
  double _glitchY = 0;

  late AnimationController _shuffleController;
  late AnimationController _spreadController;
  late Animation<double> _shuffleAnimation;

  @override
  void initState() {
    super.initState();
    _shuffleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _spreadController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _shuffleAnimation = CurvedAnimation(
      parent: _shuffleController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _shuffleController.dispose();
    _spreadController.dispose();
    _glitchTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playScarySound() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // Use BytesSource for better compatibility or just the filename
      await _audioPlayer.play(AssetSource('sound/whisper_sound.mp3'));
    } catch (e) {
      debugPrint('Audio error: $e');
    }
  }

  Future<void> _stopSound() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Stop audio error: $e');
    }
  }

  void _startGlitchAnimation() {
    _glitchTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (mounted) {
        setState(() {
          _glitchX = (_random.nextDouble() - 0.5) * 12;
          _glitchY = (_random.nextDouble() - 0.5) * 6;
        });
      }
    });
  }

  void _stopGlitchAnimation() {
    _glitchTimer?.cancel();
    _glitchTimer = null;
  }

  Future<void> _splitCards() async {
    setState(() {
      _isShuffling = true;
    });

    await _shuffleController.forward();
    
    final predictionResult = await _predictionService.getRandomPrediction();
    _prediction = predictionResult.text;
    _isScaryMode = predictionResult.isScary;
    
    if (_isScaryMode) {
      _selectedCards = List.generate(5, (_) => 'data/cards/devil13.jpg');
      _startGlitchAnimation();
      _playScarySound();
    } else {
      _selectedCards = _cardService.getRandomCards(5);
    }

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isShuffling = false;
      _showDeck = false;
    });

    await _spreadController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _cardsRevealed = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() {
      _showPrediction = true;
    });
  }

  void _reset() {
    _shuffleController.reset();
    _spreadController.reset();
    _stopSound();
    _stopGlitchAnimation();
    setState(() {
      _selectedCards = [];
      _prediction = '';
      _showDeck = true;
      _isShuffling = false;
      _cardsRevealed = false;
      _showPrediction = false;
      _isScaryMode = false;
      _glitchX = 0;
      _glitchY = 0;
    });
  }

  List<Color> get _normalGradient => const [
    Color(0xFF0D0D1A),
    Color(0xFF1A1A2E),
    Color(0xFF2D1B47),
  ];

  List<Color> get _scaryGradient => const [
    Color(0xFF0A0000),
    Color(0xFF1A0505),
    Color(0xFF2D0A0A),
    Color(0xFF0D0000),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isScaryMode ? _scaryGradient : _normalGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header - hidden in scary mode after cards shown
              if (!_isScaryMode || _showDeck)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _stopSound();
                          _stopGlitchAnimation();
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xFFE8D5B7),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'قراءة الكارطة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE8D5B7),
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              
              // Minimal back button in scary mode
              if (_isScaryMode && !_showDeck)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () {
                        _stopSound();
                        _stopGlitchAnimation();
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF8B0000),
                      ),
                    ),
                  ),
                ),

              Expanded(
                child: _showDeck ? _buildDeckView() : _buildCardsView(),
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: _showDeck
                    ? _buildSplitButton()
                    : _showPrediction
                        ? _buildReadAgainButton()
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeckView() {
    return Center(
      child: AnimatedBuilder(
        animation: _shuffleAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: List.generate(10, (index) {
              double baseOffset = (index - 5) * 2.0;
              double shuffleOffset = sin(_shuffleAnimation.value * pi * 4 + index) * 30;
              double rotation = sin(_shuffleAnimation.value * pi * 2 + index * 0.5) * 0.1;
              
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..translate(
                    _isShuffling ? shuffleOffset : 0.0,
                    baseOffset,
                  )
                  ..rotateZ(_isShuffling ? rotation : 0),
                child: Container(
                  width: 120,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9B59B6).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'data/cards/back.gif',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildCardsView() {
    return SingleChildScrollView(
      clipBehavior: Clip.none,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Cards section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double cardWidth = (constraints.maxWidth - 40) / 5;
                  cardWidth = cardWidth.clamp(55.0, 80.0);
                  double cardHeight = cardWidth * 1.5;

                  return Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    runSpacing: 12,
                    children: List.generate(_selectedCards.length, (index) {
                      return AnimatedBuilder(
                        animation: _spreadController,
                        builder: (context, child) {
                          double delay = index * 0.15;
                          double progress = ((_spreadController.value - delay) / (1 - delay)).clamp(0.0, 1.0);
                          
                          return Transform.scale(
                            scale: progress,
                            child: Opacity(
                              opacity: progress,
                              child: TarotCard(
                                frontImage: _selectedCards[index],
                                backImage: 'data/cards/back.gif',
                                width: cardWidth,
                                height: cardHeight,
                                isFlipped: _cardsRevealed,
                                flipDelay: Duration(milliseconds: 200 * index),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  );
                },
              ),
            ),

            // Prediction text
            AnimatedOpacity(
              opacity: _showPrediction ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              child: _isScaryMode 
                  ? _buildGlitchyPrediction()
                  : _buildNormalPrediction(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlitchyPrediction() {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Red glitch layer (offset)
          Transform.translate(
            offset: Offset(-4 + _glitchX, _glitchY),
            child: Opacity(
              opacity: 0.6,
              child: _buildGlitchText(const Color(0xFFFF0000)),
            ),
          ),
          // Cyan glitch layer (offset opposite)
          Transform.translate(
            offset: Offset(4 - _glitchX, -_glitchY),
            child: Opacity(
              opacity: 0.4,
              child: _buildGlitchText(const Color(0xFF00FFFF)),
            ),
          ),
          // Main text layer
          _buildGlitchText(const Color(0xFFCC0000)),
        ],
      ),
    );
  }

  Widget _buildGlitchText(Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Text(
        _prediction,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontSize: 16,
          color: textColor,
          height: 1.8,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(
              color: textColor.withValues(alpha: 0.8),
              blurRadius: 15,
            ),
            Shadow(
              color: const Color(0xFF000000),
              blurRadius: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalPrediction() {
    return AnimatedSlide(
      offset: _showPrediction ? Offset.zero : const Offset(0, 0.3),
      duration: const Duration(milliseconds: 800),
      child: Container(
        margin: const EdgeInsets.only(top: 16, left: 8, right: 8, bottom: 8),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxHeight: 250),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF2D1B47).withValues(alpha: 0.9),
              const Color(0xFF1A1A2E).withValues(alpha: 0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9B59B6).withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Text(
            _prediction,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFFE8D5B7),
              height: 1.7,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSplitButton() {
    return GestureDetector(
      onTap: _isShuffling ? null : _splitCards,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isShuffling
                ? [
                    const Color(0xFF4A4A4A),
                    const Color(0xFF3A3A3A),
                  ]
                : [
                    const Color(0xFF6B3FA0),
                    const Color(0xFF9B59B6),
                    const Color(0xFF6B3FA0),
                  ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9B59B6).withValues(alpha: _isShuffling ? 0.2 : 0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isShuffling ? Icons.hourglass_top : Icons.style,
              color: const Color(0xFFE8D5B7),
            ),
            const SizedBox(width: 12),
            Text(
              _isShuffling ? 'جاري الخلط...' : 'قسم الكروت',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE8D5B7),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadAgainButton() {
    return GestureDetector(
      onTap: _reset,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isScaryMode
                ? [
                    const Color(0xFF4A0000),
                    const Color(0xFF8B0000),
                    const Color(0xFF4A0000),
                  ]
                : [
                    const Color(0xFF6B3FA0),
                    const Color(0xFF9B59B6),
                    const Color(0xFF6B3FA0),
                  ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _isScaryMode
                  ? const Color(0xFF8B0000).withValues(alpha: 0.6)
                  : const Color(0xFF9B59B6).withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isScaryMode ? Icons.warning : Icons.refresh,
              color: _isScaryMode 
                  ? const Color(0xFFFFCCCC) 
                  : const Color(0xFFE8D5B7),
            ),
            const SizedBox(width: 12),
            Text(
              _isScaryMode ? 'الهروب...' : 'اقرأ مرة أخرى',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isScaryMode 
                    ? const Color(0xFFFFCCCC) 
                    : const Color(0xFFE8D5B7),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
