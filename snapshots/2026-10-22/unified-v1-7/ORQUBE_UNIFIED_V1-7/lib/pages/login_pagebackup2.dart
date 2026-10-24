import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// ORQUBE 로그인 화면
///
/// 핵심 원칙
/// 1. Web Google 로그인은 FirebaseAuth.signInWithPopup() 사용
/// 2. 로그인 성공 후 Navigator로 화면을 직접 이동하지 않음
/// 3. main_mobile.dart의 AuthGate가 authStateChanges()를 감지해 화면을 교체
class LoginPage extends StatefulWidget {
  final Future<void> Function()? onLoginSuccess;

  const LoginPage({super.key, this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _runLogin(Future<UserCredential> Function() loginAction) async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final credential = await loginAction();

      if (credential.user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: '로그인 사용자 정보를 확인할 수 없습니다.',
        );
      }

      await widget.onLoginSuccess?.call();

      // Navigator.push / pushReplacement를 호출하지 않습니다.
      // AuthGate가 Firebase 로그인 상태 변경을 감지해 자동 전환합니다.
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _firebaseMessage(e);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '로그인 중 오류가 발생했습니다.\n$e';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    await _runLogin(
      () => FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  Future<void> _createAccountWithEmail() async {
    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final signupFormKey = GlobalKey<FormState>();
    bool obscurePassword = true;
    bool obscureConfirmPassword = true;

    final shouldCreate = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0B0B18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: const BorderSide(color: Color(0xFFD7FF35), width: 1.2),
              ),
              title: const Text(
                '이메일 회원가입',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: SizedBox(
                width: 390,
                child: Form(
                  key: signupFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: _dialogInputDecoration(
                          label: '이메일',
                          icon: Icons.email_outlined,
                        ),
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) return '이메일을 입력해 주세요.';
                          if (!email.contains('@')) {
                            return '올바른 이메일 주소를 입력해 주세요.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: _dialogInputDecoration(
                          label: '비밀번호',
                          icon: Icons.lock_outline,
                          suffix: IconButton(
                            onPressed: () {
                              setDialogState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if ((value ?? '').length < 6) {
                            return '비밀번호는 6자 이상이어야 합니다.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirmPassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: _dialogInputDecoration(
                          label: '비밀번호 확인',
                          icon: Icons.lock_reset_outlined,
                          suffix: IconButton(
                            onPressed: () {
                              setDialogState(() {
                                obscureConfirmPassword =
                                    !obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value != passwordController.text) {
                            return '비밀번호가 서로 일치하지 않습니다.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text(
                    '취소',
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    if (signupFormKey.currentState!.validate()) {
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD7FF35),
                    foregroundColor: const Color(0xFF101015),
                  ),
                  child: const Text(
                    '회원가입',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldCreate == true) {
      _emailController.text = emailController.text.trim();
      _passwordController.text = passwordController.text;

      await _runLogin(
        () => FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        ),
      );
    }

    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  Future<void> _signInWithGoogle() async {
    await _runLogin(() async {
      final provider = GoogleAuthProvider();

      if (kIsWeb) {
        // orqubic.com 모바일 Chrome에서도 Firebase 팝업 방식으로 실행됩니다.
        return FirebaseAuth.instance.signInWithPopup(provider);
      }

      // Android APK Google 로그인은 SHA-1/SHA-256 등록 후 사용합니다.
      // FlutterFire가 지원하는 네이티브 Provider 로그인 방식입니다.
      return FirebaseAuth.instance.signInWithProvider(provider);
    });
  }

  String _firebaseMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'popup-closed-by-user':
        return 'Google 로그인 창이 닫혔습니다. 다시 시도해 주세요.';
      case 'popup-blocked':
        return '브라우저가 Google 로그인 팝업을 차단했습니다.\n'
            '주소창의 팝업 허용을 켠 뒤 다시 시도해 주세요.';
      case 'unauthorized-domain':
        return '현재 도메인이 Firebase 승인된 도메인에 등록되지 않았습니다.\n'
            'Firebase Console에서 orqubic.com과 www.orqubic.com을 추가해 주세요.';
      case 'operation-not-allowed':
        return 'Firebase Authentication에서 Google 로그인이 활성화되지 않았습니다.';
      case 'account-exists-with-different-credential':
        return '같은 이메일이 다른 로그인 방식으로 이미 가입되어 있습니다.';
      case 'network-request-failed':
        return '네트워크 연결을 확인한 뒤 다시 시도해 주세요.';
      case 'invalid-email':
        return '이메일 주소 형식이 올바르지 않습니다.';
      case 'user-disabled':
        return '사용이 중지된 계정입니다.';
      case 'user-not-found':
        return '등록되지 않은 이메일입니다.';
      case 'wrong-password':
      case 'invalid-credential':
        return '이메일 또는 비밀번호가 올바르지 않습니다.';
      case 'too-many-requests':
        return '로그인 시도가 너무 많습니다. 잠시 후 다시 시도해 주세요.';
      default:
        return error.message ?? 'Firebase 로그인 오류가 발생했습니다. (${error.code})';
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF050510);
    const panel = Color(0xFF0B0B18);
    const purple = Color(0xFF8B2CF6);
    const lime = Color(0xFFD7FF35);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: purple.withValues(alpha: 0.55)),
                  boxShadow: [
                    BoxShadow(
                      color: purple.withValues(alpha: 0.20),
                      blurRadius: 32,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: lime, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: purple.withValues(alpha: 0.45),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo/orqube_plane_logo.png',
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const Icon(
                                  Icons.flight_takeoff_rounded,
                                  size: 48,
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'ORQUBE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '계정에 로그인하세요',
                        style: TextStyle(color: Colors.white60),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          label: '이메일',
                          icon: Icons.email_outlined,
                        ),
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) return '이메일을 입력해 주세요.';
                          if (!email.contains('@')) {
                            return '올바른 이메일 주소를 입력해 주세요.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        autofillHints: const [AutofillHints.password],
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          label: '비밀번호',
                          icon: Icons.lock_outline,
                          suffix: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if ((value ?? '').isEmpty) {
                            return '비밀번호를 입력해 주세요.';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _signInWithEmail(),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.redAccent.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _loading ? null : _signInWithEmail,
                          style: FilledButton.styleFrom(
                            backgroundColor: purple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child:
                              _loading
                                  ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text(
                                    '이메일 로그인',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: _loading ? null : _createAccountWithEmail,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: lime,
                            side: const BorderSide(color: lime, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.person_add_alt_1_outlined),
                          label: const Text(
                            '이메일 회원가입',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white24)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '또는',
                              style: TextStyle(color: Colors.white38),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white24)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: _loading ? null : _signInWithGoogle,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFF2A1746),
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Color(0xFF8B5CF6),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Text(
                            'G',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          label: const Text(
                            'Google로 계속하기',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      if (kIsWeb) ...[
                        const SizedBox(height: 14),
                        const Text(
                          'Google 로그인 창이 뜨지 않으면 브라우저의 팝업 차단을 해제해 주세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white54),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.04),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF8B2CF6), width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  static InputDecoration _dialogInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white54),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.04),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD7FF35), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
