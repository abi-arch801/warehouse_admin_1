import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _pulseController;

  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  bool _navigated = false;
  int _taglineIndex = 0;

  static const _taglines = [
    'Sistem Manajemen Gudang IPAL',
    'Pantau Stok Secara Real-Time',
    'Setujui Permintaan Lebih Cepat',
    'Laporan Dalam Genggaman',
  ];

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    _fade = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _scale = Tween<double>(
      begin: 0.82,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOutBack,
      ),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, .18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOutCubic,
      ),
    );

    _entryController.forward();

    _rotateText();
    Future.delayed(
      const Duration(milliseconds: 2400),
      _goToLogin,
    );
  }

  Future<void> _rotateText() async {
    while (mounted && !_navigated) {
      await Future.delayed(const Duration(milliseconds: 1300));
      if (!mounted || _navigated) return;

      setState(() {
        _taglineIndex = (_taglineIndex + 1) % _taglines.length;
      });
    }
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
          decoration: const BoxDecoration(
            gradient: AppTheme.splashGradient,
          ),
          child: SafeArea(
            child: Stack(
              children: [
                _buildParticles(),
                Center(
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLogo(),
                          const SizedBox(height: 28),
                          const Text(
                            'GudangPro',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.16),
                              borderRadius:
                                  BorderRadius.circular(99),
                            ),
                            child: const Text(
                              'ADMIN PANEL',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          AnimatedSwitcher(
                            duration:
                                const Duration(milliseconds: 350),
                            transitionBuilder:
                                (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin:
                                        const Offset(0, .2),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              _taglines[_taglineIndex],
                              key: ValueKey(_taglineIndex),
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.white
                                    .withOpacity(.92),
                              ),
                            ),
                          ),
                          const SizedBox(height: 42),
                          const _DotLoader(),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 26,
                  left: 0,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) {
                      return Opacity(
                        opacity:
                            .45 + (_pulseController.value * .4),
                        child: const Center(
                          child: Text(
                            'Ketuk layar untuk lanjut',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) {
        final pulse = 1 + (_pulseController.value * .035);

        return Transform.scale(
          scale: pulse,
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              width: 126,
              height: 126,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(34),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.18),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                color: AppTheme.primary,
                size: 68,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticles() {
    return IgnorePointer(
      child: Stack(
        children: List.generate(8, (i) {
          return Positioned(
            top: 70 + (i * 78),
            left: 20 + ((i * 41) % 280),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) {
                final size =
                    5.0 + ((i % 3) * 2) + _pulseController.value;

                return Opacity(
                  opacity: .08 +
                      (_pulseController.value * .14),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          );
        }),
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
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final t =
                (_controller.value + (i * .18)) % 1.0;

            final scale =
                .65 + (.45 * (1 - (t - .5).abs() * 2));

            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              width: 10 * scale,
              height: 10 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(
                  .35 + (.55 * scale),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}