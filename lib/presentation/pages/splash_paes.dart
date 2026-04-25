import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Splash Screen — Versi interaktif:
//   • Logo skala elastis + fade in
//   • Subtitle berputar (rotating tagline)
//   • Indikator titik berdenyut
//   • Tap layar di mana saja untuk skip langsung ke Login
//   • Auto-navigate ke /login setelah 2.4 dtk
// ─────────────────────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _pulseController;
  late Animation<double> _scale;
  late Animation<double> _fade;

  bool _navigated = false;
  int _taglineIndex = 0;
  static const _taglines = [
    'Sistem Manajemen Gudang IPAL',
    'Pantau Stok Secara Real-Time',
    'Setujui Permintaan dengan Mudah',
    'Laporan Bulanan dalam Genggaman',
  ];

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _entryController.forward();

    // Tagline rotation
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 1400));
      if (!mounted || _navigated) return false;
      setState(() => _taglineIndex = (_taglineIndex + 1) % _taglines.length);
      return true;
    });

    // Auto navigate
    Future.delayed(const Duration(milliseconds: 2400), _goToLogin);
  }

  void _goToLogin() {
    if (_navigated || !mounted) return;
    _navigated = true;
    HapticFeedback.lightImpact();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _goToLogin,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: const BoxDecoration(gradient: AppTheme.splashGradient),
          child: SafeArea(
            child: Stack(
              children: [
                // Particle dots
                ...List.generate(8, (i) {
                  return Positioned(
                    top: 60.0 + (i * 70) % 600,
                    left: ((i * 91) % 320).toDouble(),
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) => Opacity(
                        opacity: 0.18 + 0.18 * _pulseController.value,
                        child: Container(
                          width: 6.0 + (i % 3) * 3,
                          height: 6.0 + (i % 3) * 3,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                // Center content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _scale,
                        child: FadeTransition(
                          opacity: _fade,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (_, child) => Transform.scale(
                              scale: 1 + 0.04 * _pulseController.value,
                              child: child,
                            ),
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(36),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 36,
                                    offset: const Offset(0, 16),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.admin_panel_settings_rounded,
                                color: AppTheme.primary,
                                size: 70,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      FadeTransition(
                        opacity: _fade,
                        child: const Text(
                          'GudangPro',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      FadeTransition(
                        opacity: _fade,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'ADMIN PANEL',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          _taglines[_taglineIndex],
                          key: ValueKey(_taglineIndex),
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white.withOpacity(0.95),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      const _DotLoader(),
                    ],
                  ),
                ),
                // Tap to skip hint
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) => Opacity(
                      opacity: 0.5 + 0.4 * _pulseController.value,
                      child: const Center(
                        child: Text(
                          'Ketuk layar untuk lanjut',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DotLoader extends StatefulWidget {
  const _DotLoader();
  @override
  State<_DotLoader> createState() => _DotLoaderState();
}

class _DotLoaderState extends State<_DotLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final t = ((_c.value + i / 3) % 1.0);
            final s = 0.6 + 0.5 * (1 - (t - 0.5).abs() * 2).clamp(0, 1);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 10 * s,
              height: 10 * s,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4 + 0.6 * s),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
