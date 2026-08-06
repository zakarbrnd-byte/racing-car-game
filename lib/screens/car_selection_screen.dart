import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/car.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';

class CarSelectionScreen extends StatefulWidget {
  const CarSelectionScreen({super.key});

  @override
  State<CarSelectionScreen> createState() => _CarSelectionScreenState();
}

class _CarSelectionScreenState extends State<CarSelectionScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _pulseController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.78);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Car get _selectedCar => Car.all[_selectedIndex];

  void _startRace() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: GameScreen(car: _selectedCar),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1118),
              AppTheme.asphalt,
              Color(0xFF121820),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                'LANE RUSH',
                style: GoogleFonts.bebasNeue(
                  fontSize: 52,
                  letterSpacing: 6,
                  color: AppTheme.cream,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pick your ride',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: AppTheme.cream.withValues(alpha: 0.65),
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: Car.all.length,
                  onPageChanged: (index) => setState(() => _selectedIndex = index),
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        var scale = 1.0;
                        if (_pageController.position.haveDimensions) {
                          final page = _pageController.page ?? _selectedIndex.toDouble();
                          scale = (1 - (page - index).abs() * 0.18).clamp(0.82, 1.0);
                        } else if (index != _selectedIndex) {
                          scale = 0.82;
                        }
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: _CarCard(
                        car: Car.all[index],
                        selected: index == _selectedIndex,
                        pulse: _pulseController,
                        maxHeight: size.height * 0.48,
                      ),
                    );
                  },
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Column(
                  key: ValueKey(_selectedCar.id),
                  children: [
                    Text(
                      _selectedCar.name,
                      style: GoogleFonts.bebasNeue(
                        fontSize: 36,
                        letterSpacing: 2,
                        color: _selectedCar.accentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedCar.tagline,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: AppTheme.cream.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(Car.all.length, (i) {
                  final active = i == _selectedIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? _selectedCar.accentColor
                          : AppTheme.cream.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startRace,
                    child: const Text('START RACE'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Swipe to choose  ·  Tap lanes to steer',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppTheme.cream.withValues(alpha: 0.45),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarCard extends StatelessWidget {
  const _CarCard({
    required this.car,
    required this.selected,
    required this.pulse,
    required this.maxHeight,
  });

  final Car car;
  final bool selected;
  final AnimationController pulse;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        final glow = selected ? 10 + pulse.value * 14 : 0.0;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.asphaltLight.withValues(alpha: 0.9),
                const Color(0xFF151A24),
              ],
            ),
            border: Border.all(
              color: selected
                  ? car.accentColor.withValues(alpha: 0.85)
                  : AppTheme.cream.withValues(alpha: 0.12),
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: car.accentColor.withValues(alpha: 0.35),
                      blurRadius: glow,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Hero(
              tag: 'car-${car.id}',
              child: Image.asset(
                car.assetPath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
