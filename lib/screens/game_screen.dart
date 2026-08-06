import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/car.dart';
import '../theme/app_theme.dart';

enum GameStatus { playing, paused, gameOver }

class Obstacle {
  Obstacle({
    required this.lane,
    required this.y,
    required this.width,
    required this.height,
    required this.kind,
  });

  int lane;
  double y;
  final double width;
  final double height;
  final ObstacleKind kind;
}

enum ObstacleKind { cone, barrier, oil }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.car});

  final Car car;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  static const int laneCount = 3;
  static const double playerCarHeight = 110;
  static const double playerCarWidth = 64;

  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  GameStatus _status = GameStatus.playing;
  int _lane = 1;
  double _laneAnim = 1;
  double _roadOffset = 0;
  double _speed = 280;
  double _distance = 0;
  double _spawnTimer = 0;
  double _spawnInterval = 1.35;
  final List<Obstacle> _obstacles = [];
  final math.Random _rng = math.Random();
  int _score = 0;
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_status != GameStatus.playing) {
      _lastTick = elapsed;
      return;
    }

    final dt = _lastTick == Duration.zero
        ? 0.0
        : (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (dt <= 0 || dt > 0.1) return;

    final size = MediaQuery.sizeOf(context);
    final roadTop = 0.0;
    final roadBottom = size.height;
    final playerY = roadBottom - playerCarHeight - 48;

    setState(() {
      _speed = math.min(520, 280 + _distance * 0.012);
      _roadOffset = (_roadOffset + _speed * dt) % 80;
      _distance += _speed * dt;
      _score = (_distance / 10).floor();

      // Smooth lane change
      _laneAnim += (_lane - _laneAnim) * math.min(1, dt * 12);

      _spawnTimer += dt;
      if (_spawnTimer >= _spawnInterval) {
        _spawnTimer = 0;
        _spawnInterval = math.max(0.65, 1.35 - _distance / 8000);
        _spawnObstacle();
      }

      for (final obstacle in _obstacles) {
        obstacle.y += _speed * dt;
      }
      _obstacles.removeWhere((o) => o.y > roadBottom + 40);

      _checkCollisions(size.width, playerY, roadTop);
    });
  }

  void _spawnObstacle() {
    final lane = _rng.nextInt(laneCount);
    // Avoid packing same lane as the last obstacle too tightly
    if (_obstacles.isNotEmpty &&
        _obstacles.last.lane == lane &&
        _obstacles.last.y < 160) {
      return;
    }

    final kind = ObstacleKind.values[_rng.nextInt(ObstacleKind.values.length)];
    final dims = switch (kind) {
      ObstacleKind.cone => (42.0, 48.0),
      ObstacleKind.barrier => (58.0, 36.0),
      ObstacleKind.oil => (50.0, 34.0),
    };

    _obstacles.add(
      Obstacle(
        lane: lane,
        y: -dims.$2 - 20,
        width: dims.$1,
        height: dims.$2,
        kind: kind,
      ),
    );

    // Occasional second obstacle in another lane
    if (_rng.nextDouble() < 0.28) {
      var other = _rng.nextInt(laneCount);
      if (other == lane) other = (lane + 1) % laneCount;
      _obstacles.add(
        Obstacle(
          lane: other,
          y: -dims.$2 - 120,
          width: dims.$1,
          height: dims.$2,
          kind: ObstacleKind.values[_rng.nextInt(ObstacleKind.values.length)],
        ),
      );
    }
  }

  void _checkCollisions(double screenWidth, double playerY, double roadTop) {
    final laneWidth = screenWidth / laneCount;
    final playerCenterX = (_laneAnim + 0.5) * laneWidth;
    final playerRect = Rect.fromCenter(
      center: Offset(playerCenterX, playerY + playerCarHeight / 2),
      width: playerCarWidth * 0.55,
      height: playerCarHeight * 0.7,
    );

    for (final obstacle in _obstacles) {
      final ox = (obstacle.lane + 0.5) * laneWidth;
      final obstacleRect = Rect.fromCenter(
        center: Offset(ox, obstacle.y + obstacle.height / 2),
        width: obstacle.width * 0.75,
        height: obstacle.height * 0.8,
      );
      if (playerRect.overlaps(obstacleRect)) {
        _status = GameStatus.gameOver;
        _highScore = math.max(_highScore, _score);
        break;
      }
    }
  }

  void _moveLeft() {
    if (_status != GameStatus.playing) return;
    setState(() => _lane = math.max(0, _lane - 1));
  }

  void _moveRight() {
    if (_status != GameStatus.playing) return;
    setState(() => _lane = math.min(laneCount - 1, _lane + 1));
  }

  void _restart() {
    setState(() {
      _status = GameStatus.playing;
      _lane = 1;
      _laneAnim = 1;
      _roadOffset = 0;
      _speed = 280;
      _distance = 0;
      _spawnTimer = 0;
      _spawnInterval = 1.35;
      _obstacles.clear();
      _score = 0;
      _lastTick = Duration.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final laneWidth = size.width / laneCount;
    final playerY = size.height - playerCarHeight - 48;
    final playerX = (_laneAnim + 0.5) * laneWidth - playerCarWidth / 2;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: (details) {
          final v = details.primaryVelocity ?? 0;
          if (v < -200) {
            _moveLeft();
          } else if (v > 200) {
            _moveRight();
          }
        },
        onTapUp: (details) {
          if (_status == GameStatus.gameOver) return;
          if (details.localPosition.dx < size.width / 2) {
            _moveLeft();
          } else {
            _moveRight();
          }
        },
        child: Stack(
          children: [
            CustomPaint(
              size: size,
              painter: _RoadPainter(offset: _roadOffset, laneCount: laneCount),
            ),
            ..._obstacles.map((o) {
              final left = (o.lane + 0.5) * laneWidth - o.width / 2;
              return Positioned(
                left: left,
                top: o.y,
                width: o.width,
                height: o.height,
                child: _ObstacleView(kind: o.kind),
              );
            }),
            Positioned(
              left: playerX,
              top: playerY,
              width: playerCarWidth,
              height: playerCarHeight,
              child: Hero(
                tag: 'car-${widget.car.id}',
                child: Image.asset(
                  widget.car.assetPath,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppTheme.cream,
                    ),
                    const Spacer(),
                    _HudChip(
                      label: 'SCORE',
                      value: '$_score',
                      color: widget.car.accentColor,
                    ),
                    const SizedBox(width: 10),
                    _HudChip(
                      label: 'SPEED',
                      value: '${(_speed / 10).round()}',
                      color: AppTheme.roadMark,
                    ),
                  ],
                ),
              ),
            ),
            if (_status == GameStatus.gameOver) _GameOverOverlay(
              score: _score,
              highScore: _highScore,
              accent: widget.car.accentColor,
              onRetry: _restart,
              onMenu: () => Navigator.of(context).pop(),
            ),
            if (_status == GameStatus.playing)
              Positioned(
                left: 0,
                right: 0,
                bottom: 12,
                child: Text(
                  '← swipe or tap sides to steer →',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppTheme.cream.withValues(alpha: 0.4),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HudChip extends StatelessWidget {
  const _HudChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 10,
              letterSpacing: 1.2,
              color: AppTheme.cream.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.bebasNeue(
              fontSize: 22,
              height: 1,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  const _GameOverOverlay({
    required this.score,
    required this.highScore,
    required this.accent,
    required this.onRetry,
    required this.onMenu,
  });

  final int score;
  final int highScore;
  final Color accent;
  final VoidCallback onRetry;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.72),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 22),
          decoration: BoxDecoration(
            color: AppTheme.asphaltLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CRASHED',
                style: GoogleFonts.bebasNeue(
                  fontSize: 44,
                  letterSpacing: 3,
                  color: AppTheme.danger,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Score  $score',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cream,
                ),
              ),
              Text(
                'Best  $highScore',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppTheme.cream.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('RACE AGAIN'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: onMenu,
                child: Text(
                  'Change car',
                  style: GoogleFonts.outfit(
                    color: AppTheme.cream.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ObstacleView extends StatelessWidget {
  const _ObstacleView({required this.kind});

  final ObstacleKind kind;

  @override
  Widget build(BuildContext context) {
    return switch (kind) {
      ObstacleKind.cone => CustomPaint(painter: _ConePainter()),
      ObstacleKind.barrier => CustomPaint(painter: _BarrierPainter()),
      ObstacleKind.oil => CustomPaint(painter: _OilPainter()),
    };
  }
}

class _ConePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.88, size.height * 0.92)
      ..lineTo(size.width * 0.12, size.height * 0.92)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFF8A3D));
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.18, size.height * 0.35, size.width * 0.64, size.height * 0.12),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.88, size.width, size.height * 0.12),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF2A2A2A),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BarrierPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.15, size.width, size.height * 0.7),
      const Radius.circular(4),
    );
    canvas.drawRRect(r, Paint()..color = const Color(0xFFFFD54F));
    final stripe = Paint()..color = const Color(0xFF1A1A1A);
    for (var i = 0; i < 4; i++) {
      final x = size.width * (0.12 + i * 0.22);
      canvas.drawRect(
        Rect.fromLTWH(x, size.height * 0.2, size.width * 0.12, size.height * 0.6),
        stripe,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OilPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF4A148C).withValues(alpha: 0.85),
          const Color(0xFF1A237E).withValues(alpha: 0.55),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawOval(Rect.fromLTWH(0, size.height * 0.15, size.width, size.height * 0.7), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoadPainter extends CustomPainter {
  _RoadPainter({required this.offset, required this.laneCount});

  final double offset;
  final int laneCount;

  @override
  void paint(Canvas canvas, Size size) {
    // Grass / roadside
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF14352C), Color(0xFF0F241E)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    final roadWidth = size.width * 0.92;
    final roadLeft = (size.width - roadWidth) / 2;
    final roadRect = Rect.fromLTWH(roadLeft, 0, roadWidth, size.height);

    canvas.drawRect(
      roadRect,
      Paint()..color = const Color(0xFF2B303B),
    );

    // Soft edge fade
    canvas.drawRect(
      Rect.fromLTWH(roadLeft, 0, 10, size.height),
      Paint()..color = const Color(0xFF1E222A),
    );
    canvas.drawRect(
      Rect.fromLTWH(roadLeft + roadWidth - 10, 0, 10, size.height),
      Paint()..color = const Color(0xFF1E222A),
    );

    final laneWidth = size.width / laneCount;
    final dashPaint = Paint()
      ..color = AppTheme.roadMark.withValues(alpha: 0.85)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    for (var lane = 1; lane < laneCount; lane++) {
      final x = lane * laneWidth;
      var y = -80.0 + offset;
      while (y < size.height + 40) {
        canvas.drawLine(Offset(x, y), Offset(x, y + 28), dashPaint);
        y += 56;
      }
    }

    // Side reflectors
    final reflector = Paint()..color = const Color(0xFFE8B84A);
    var ry = -40.0 + offset * 0.9;
    while (ry < size.height) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(roadLeft + 4, ry, 6, 14),
          const Radius.circular(2),
        ),
        reflector,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(roadLeft + roadWidth - 10, ry, 6, 14),
          const Radius.circular(2),
        ),
        reflector,
      );
      ry += 70;
    }
  }

  @override
  bool shouldRepaint(covariant _RoadPainter oldDelegate) =>
      oldDelegate.offset != offset;
}
