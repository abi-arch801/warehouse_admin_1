import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _userCtrl = TextEditingController(text: 'admin@gudangpro.id');
  final _passCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  bool _remember = true;

  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  final List<Map<String, dynamic>> _demoAccounts = const [
    {
      'label': 'Super Admin',
      'email': 'admin@gudangpro.id',
      'pass': 'admin123',
      'icon': Icons.admin_panel_settings_rounded,
    },
    {
      'label': 'Operator',
      'email': 'operator@gudangpro.id',
      'pass': 'operator123',
      'icon': Icons.engineering_rounded,
    },
    {
      'label': 'Auditor',
      'email': 'audit@gudangpro.id',
      'pass': 'audit123',
      'icon': Icons.verified_user_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fade = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, .06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: Curves.easeOutCubic,
      ),
    );

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }

    HapticFeedback.mediumImpact();

    setState(() => _loading = true);

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    setState(() => _loading = false);

    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  void _useDemo(Map<String, dynamic> data) {
    HapticFeedback.selectionClick();

    setState(() {
      _userCtrl.text = data['email'];
      _passCtrl.text = data['pass'];
    });

    _snack('Akun ${data['label']} dimuat');
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text(text),
        ),
      );
  }

  void _forgotPassword() {
    final ctrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            14,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 18),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Admin',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ctrl.dispose();
                    _snack('Link reset dikirim');
                  },
                  child: const Text('Kirim'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email wajib diisi';

    final ok = RegExp(
      r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
    ).hasMatch(v.trim());

    if (!ok) return 'Email ga valid';

    return null;
  }

  String? _passValidator(String? v) {
    if (v == null || v.isEmpty) return 'Password wajib diisi';
    if (v.length < 6) return 'Minimal 6 karakter';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    children: [
                      const SizedBox(height: 18),
                      Hero(
                        tag: 'app_logo',
                        child: Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                                color: Colors.black.withOpacity(.16),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            color: AppTheme.primary,
                            size: 42,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Selamat Datang',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Masuk buat kelola gudang',
                        style: TextStyle(
                          color: Colors.white.withOpacity(.9),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black.withOpacity(.04),
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 28,
                              offset: const Offset(0, 12),
                              color: AppTheme.primary.withOpacity(.12),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _userCtrl,
                                validator: _emailValidator,
                                keyboardType:
                                    TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email Admin',
                                  prefixIcon:
                                      Icon(Icons.email_outlined),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passCtrl,
                                obscureText: _obscure,
                                validator: _passValidator,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscure = !_obscure;
                                      });
                                    },
                                    icon: Icon(
                                      _obscure
                                          ? Icons
                                              .visibility_off_outlined
                                          : Icons
                                              .visibility_outlined,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Switch(
                                    value: _remember,
                                    activeColor:
                                        AppTheme.primary,
                                    onChanged: (v) {
                                      setState(() {
                                        _remember = v;
                                      });
                                    },
                                  ),
                                  const Text(
                                    'Ingat saya',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: _forgotPassword,
                                    child: const Text(
                                      'Lupa Password?',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 54,
                                      child: ElevatedButton(
                                        onPressed:
                                            _loading ? null : _login,
                                        style:
                                            ElevatedButton.styleFrom(
                                          shape:
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        child: _loading
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth:
                                                      2.5,
                                                  color: Colors
                                                      .white,
                                                ),
                                              )
                                            : const Text(
                                                'Masuk',
                                              ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: 54,
                                    height: 54,
                                    child: Material(
                                      color: AppTheme.primary
                                          .withOpacity(.1),
                                      borderRadius:
                                          BorderRadius.circular(
                                              16),
                                      child: InkWell(
                                        borderRadius:
                                            BorderRadius.circular(
                                                16),
                                        onTap: () {
                                          _snack(
                                              'Biometrik coming soon 😹');
                                        },
                                        child: const Icon(
                                          Icons
                                              .fingerprint_rounded,
                                          color:
                                              AppTheme.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color:
                                          Colors.grey.shade300,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Text(
                                      'Akun Demo',
                                      style: TextStyle(
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color:
                                          Colors.grey.shade300,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 62,
                                child: ListView.separated(
                                  scrollDirection:
                                      Axis.horizontal,
                                  itemCount:
                                      _demoAccounts.length,
                                  separatorBuilder:
                                      (_, __) =>
                                          const SizedBox(
                                    width: 8,
                                  ),
                                  itemBuilder: (_, i) {
                                    final item =
                                        _demoAccounts[i];

                                    return InkWell(
                                      borderRadius:
                                          BorderRadius
                                              .circular(14),
                                      onTap: () =>
                                          _useDemo(item),
                                      child: Container(
                                        width: 130,
                                        padding:
                                            const EdgeInsets
                                                .all(10),
                                        decoration:
                                            BoxDecoration(
                                          color: AppTheme
                                              .primary
                                              .withOpacity(
                                                  .08),
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                                      14),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              item['icon'],
                                              color: AppTheme
                                                  .primary,
                                              size: 18,
                                            ),
                                            const SizedBox(
                                                width: 8),
                                            Expanded(
                                              child: Text(
                                                item[
                                                    'label'],
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                                style:
                                                    const TextStyle(
                                                  fontSize:
                                                      12,
                                                  fontWeight:
                                                      FontWeight
                                                          .w700,
                                                ),
                                              ),
                                            ),
                                          ],
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
                      const SizedBox(height: 18),
                      Text(
                        'Akses admin only',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}