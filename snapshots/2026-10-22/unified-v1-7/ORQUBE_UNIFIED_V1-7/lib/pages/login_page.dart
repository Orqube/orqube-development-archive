import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../utils/orqube_i18n.dart';
import '../services/firebase_service.dart';
import 'phone_sign_in_dialog.dart';

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

  bool _isLoading = false;
  bool _hidePassword = true;
  String? _message;

  static const Color _background = Color(0xFF050510);
  static const Color _panel = Color(0xFF0B0B18);
  static const Color _purple = Color(0xFF8B2CF6);
  static const Color _lime = Color(0xFFD7FF35);
  static const Color _googleBackground = Color(0xFF2A1746);
  static const Color _googleBorder = Color(0xFF8B5CF6);

  String _t({
    required String ko,
    required String en,
    required String ja,
    required String zh,
    required String fr,
    required String pt,
  }) {
    switch (OrqubeI18n.normalize(OrqubeI18n.currentLanguage)) {
      case 'en':
        return en;
      case 'ja':
        return ja;
      case 'zh':
        return zh;
      case 'fr':
        return fr;
      case 'pt':
        return pt;
      default:
        return ko;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || FirebaseAuth.instance.currentUser == null) return;
      // 이미 로그인된 사용자가 이동 중 로그인 화면으로 들어온 경우
      // 재가입을 요구하지 않고 원래 인증 상태를 그대로 사용합니다.
      if (widget.onLoginSuccess != null) {
        await widget.onLoginSuccess!.call();
      } else if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _runAuth(Future<UserCredential> Function() action) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final result = await action();

      if (result.user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: _t(
            ko: '사용자 정보를 확인할 수 없습니다.',
            en: 'Unable to verify the user account.',
            ja: 'ユーザー情報を確認できません。',
            zh: '无法确认用户信息。',
            fr: 'Impossible de vérifier le compte utilisateur.',
            pt: 'Não foi possível verificar a conta do usuário.',
          ),
        );
      }

      // 로그인 자체는 Firebase Auth 성공 여부만으로 완료합니다.
      // 친구초대/프로필 준비 중 Firestore 권한 또는 네트워크 문제가 생겨도
      // 정상 로그인을 막지 않도록 부가 초기화는 비차단 방식으로 처리합니다.
      try {
        await FirebaseService.createUserProfileIfNeeded();
      } catch (error, stackTrace) {
        debugPrint('[ORQUBE referral bootstrap] $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      if (!mounted) return;
      await widget.onLoginSuccess?.call();

      // 화면 이동은 main_mobile.dart의 AuthGate가 처리합니다.
      // 여기서는 Navigator를 사용하지 않습니다.
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _message = _firebaseErrorMessage(error);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _message =
            '${_t(ko: '로그인 처리 중 오류가 발생했습니다.', en: 'An error occurred while signing in.', ja: 'ログイン処理中にエラーが発生しました。', zh: '登录过程中发生错误。', fr: 'Une erreur est survenue lors de la connexion.', pt: 'Ocorreu um erro durante o login.')}\n$error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    await _runAuth(
      () => FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  Future<void> _signUpWithEmail() async {
    final signupFormKey = GlobalKey<FormState>();
    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    bool hidePassword = true;
    bool hideConfirmPassword = true;

    final shouldCreate = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _panel,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: const BorderSide(color: _lime, width: 1.3),
              ),
              title: Text(
                _t(
                  ko: '이메일 회원가입',
                  en: 'Email Sign Up',
                  ja: 'メール会員登録',
                  zh: '邮箱注册',
                  fr: 'Inscription par e-mail',
                  pt: 'Cadastro por e-mail',
                ),
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
                        decoration: _inputDecoration(
                          label: _t(
                            ko: '이메일',
                            en: 'Email',
                            ja: 'メール',
                            zh: '电子邮箱',
                            fr: 'E-mail',
                            pt: 'E-mail',
                          ),
                          icon: Icons.email_outlined,
                        ),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: passwordController,
                        obscureText: hidePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          label: _t(
                            ko: '비밀번호',
                            en: 'Password',
                            ja: 'パスワード',
                            zh: '密码',
                            fr: 'Mot de passe',
                            pt: 'Senha',
                          ),
                          icon: Icons.lock_outline,
                          suffix: IconButton(
                            onPressed: () {
                              setDialogState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if ((value ?? '').length < 6) {
                            return _t(
                              ko: '비밀번호는 6자 이상 입력해 주세요.',
                              en: 'Password must be at least 6 characters.',
                              ja: 'パスワードは6文字以上で入力してください。',
                              zh: '密码至少需要6个字符。',
                              fr:
                                  'Le mot de passe doit contenir au moins 6 caractères.',
                              pt: 'A senha deve ter pelo menos 6 caracteres.',
                            );
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: confirmController,
                        obscureText: hideConfirmPassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          label: _t(
                            ko: '비밀번호 확인',
                            en: 'Confirm Password',
                            ja: 'パスワード確認',
                            zh: '确认密码',
                            fr: 'Confirmer le mot de passe',
                            pt: 'Confirmar senha',
                          ),
                          icon: Icons.lock_reset_outlined,
                          suffix: IconButton(
                            onPressed: () {
                              setDialogState(() {
                                hideConfirmPassword = !hideConfirmPassword;
                              });
                            },
                            icon: Icon(
                              hideConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value != passwordController.text) {
                            return _t(
                              ko: '비밀번호가 일치하지 않습니다.',
                              en: 'Passwords do not match.',
                              ja: 'パスワードが一致しません。',
                              zh: '两次输入的密码不一致。',
                              fr: 'Les mots de passe ne correspondent pas.',
                              pt: 'As senhas não coincidem.',
                            );
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
                  child: Text(
                    _t(
                      ko: '취소',
                      en: 'Cancel',
                      ja: 'キャンセル',
                      zh: '取消',
                      fr: 'Annuler',
                      pt: 'Cancelar',
                    ),
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
                    backgroundColor: _lime,
                    foregroundColor: const Color(0xFF111115),
                  ),
                  child: Text(
                    _t(
                      ko: '회원가입',
                      en: 'Sign Up',
                      ja: '会員登録',
                      zh: '注册',
                      fr: 'S’inscrire',
                      pt: 'Cadastrar',
                    ),
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

      await _runAuth(
        () => FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        ),
      );
    }

    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
  }

  Future<void> _signInWithPhone() async {
    if (_isLoading) return;
    final result = await showDialog<UserCredential>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PhoneSignInDialog(),
    );
    if (result != null && mounted) {
      await _runAuth(() async => result);
    }
  }

  Future<void> _signInWithGoogle() async {
    await _runAuth(() async {
      if (kIsWeb) {
        final provider =
            GoogleAuthProvider()
              ..setCustomParameters({'prompt': 'select_account'});
        return FirebaseAuth.instance.signInWithPopup(provider);
      }

      final google = GoogleSignIn();
      await google.signOut();
      final googleUser = await google.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'popup-closed-by-user',
          message: _t(
            ko: 'Google 계정 선택이 취소되었습니다.',
            en: 'Google account selection was cancelled.',
            ja: 'Googleアカウントの選択がキャンセルされました。',
            zh: '已取消选择 Google 账号。',
            fr: 'La sélection du compte Google a été annulée.',
            pt: 'A seleção da conta Google foi cancelada.',
          ),
        );
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return FirebaseAuth.instance.signInWithCredential(credential);
    });
  }

  Future<void> _sendPasswordReset() async {
    final controller = TextEditingController(
      text: _emailController.text.trim(),
    );
    final email = await showDialog<String>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: _panel,
            title: Text(
              _t(
                ko: '비밀번호 찾기',
                en: 'Reset Password',
                ja: 'パスワードを探す',
                zh: '找回密码',
                fr: 'Réinitialiser le mot de passe',
                pt: 'Redefinir senha',
              ),
              style: const TextStyle(color: Colors.white),
            ),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                label: _t(
                  ko: '가입한 이메일',
                  en: 'Registered email',
                  ja: '登録したメール',
                  zh: '注册邮箱',
                  fr: 'E-mail enregistré',
                  pt: 'E-mail cadastrado',
                ),
                icon: Icons.email_outlined,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  _t(
                    ko: '취소',
                    en: 'Cancel',
                    ja: 'キャンセル',
                    zh: '取消',
                    fr: 'Annuler',
                    pt: 'Cancelar',
                  ),
                ),
              ),
              FilledButton(
                onPressed:
                    () => Navigator.pop(dialogContext, controller.text.trim()),
                child: Text(
                  _t(
                    ko: '재설정 메일 보내기',
                    en: 'Send reset email',
                    ja: '再設定メールを送信',
                    zh: '发送重置邮件',
                    fr: 'Envoyer l’e-mail',
                    pt: 'Enviar e-mail de redefinição',
                  ),
                ),
              ),
            ],
          ),
    );
    controller.dispose();
    if (email == null || email.isEmpty) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      setState(() {
        _emailController.text = email;
        _message = _t(
          ko: '비밀번호 재설정 메일을 보냈습니다. 메일함과 스팸함을 확인해 주세요.',
          en:
              'A password reset email was sent. Check your inbox and spam folder.',
          ja: 'パスワード再設定メールを送信しました。受信箱と迷惑メールをご確認ください。',
          zh: '密码重置邮件已发送，请检查收件箱和垃圾邮件。',
          fr:
              'Un e-mail de réinitialisation a été envoyé. Vérifiez votre boîte de réception et les courriers indésirables.',
          pt:
              'O e-mail de redefinição foi enviado. Verifique a caixa de entrada e o spam.',
        );
      });
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() => _message = _firebaseErrorMessage(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showFindId() async {
    await showDialog<void>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: _panel,
            title: Text(
              _t(
                ko: '아이디 찾기',
                en: 'Find ID',
                ja: 'IDを探す',
                zh: '找回账号',
                fr: 'Retrouver l’identifiant',
                pt: 'Encontrar ID',
              ),
              style: const TextStyle(color: Colors.white),
            ),
            content: Text(
              _t(
                ko:
                    'ORQUBE 아이디는 회원가입에 사용한 이메일 주소입니다.\n\nGoogle로 가입한 경우에는 Google 계정의 이메일 주소로 로그인해 주세요.',
                en:
                    'Your ORQUBE ID is the email address used to register.\n\nIf you registered with Google, sign in with that Google account email.',
                ja:
                    'ORQUBE IDは登録に使用したメールアドレスです。\n\nGoogleで登録した場合は、そのGoogleアカウントのメールアドレスでログインしてください。',
                zh: 'ORQUBE 账号是注册时使用的电子邮箱。\n\n如果通过 Google 注册，请使用该 Google 账号邮箱登录。',
                fr:
                    'Votre identifiant ORQUBE est l’adresse e-mail utilisée lors de l’inscription.\n\nSi vous vous êtes inscrit avec Google, connectez-vous avec l’adresse de ce compte Google.',
                pt:
                    'Seu ID ORQUBE é o e-mail usado no cadastro.\n\nSe você se cadastrou com o Google, entre com o e-mail dessa conta Google.',
              ),
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  _t(
                    ko: '확인',
                    en: 'OK',
                    ja: '確認',
                    zh: '确定',
                    fr: 'OK',
                    pt: 'OK',
                  ),
                ),
              ),
            ],
          ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return _t(
        ko: '아이디(이메일)를 입력해 주세요.',
        en: 'Enter your ID (email).',
        ja: 'ID（メール）を入力してください。',
        zh: '请输入账号（电子邮箱）。',
        fr: 'Saisissez votre identifiant (e-mail).',
        pt: 'Digite seu ID (e-mail).',
      );
    }

    if (!email.contains('@')) {
      return _t(
        ko: '아이디가 잘못 입력되었습니다.',
        en: 'The ID (email) is invalid.',
        ja: 'ID（メール）の入力が正しくありません。',
        zh: '账号（电子邮箱）输入不正确。',
        fr: 'L’identifiant (e-mail) est incorrect.',
        pt: 'O ID (e-mail) foi digitado incorretamente.',
      );
    }

    return null;
  }

  String _firebaseErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'popup-closed-by-user':
        return _t(
          ko: 'Google 로그인 창이 닫혔습니다.',
          en: 'The Google sign-in window was closed.',
          ja: 'Googleログイン画面が閉じられました。',
          zh: 'Google 登录窗口已关闭。',
          fr: 'La fenêtre de connexion Google a été fermée.',
          pt: 'A janela de login do Google foi fechada.',
        );
      case 'popup-blocked':
        return _t(
          ko: '브라우저의 팝업 차단을 해제해 주세요.',
          en: 'Allow pop-ups in your browser.',
          ja: 'ブラウザのポップアップを許可してください。',
          zh: '请允许浏览器弹出窗口。',
          fr: 'Autorisez les fenêtres contextuelles du navigateur.',
          pt: 'Permita pop-ups no navegador.',
        );
      case 'unauthorized-domain':
        return _t(
          ko: '현재 도메인은 승인된 로그인 도메인이 아닙니다.',
          en: 'This domain is not authorized for sign-in.',
          ja: '現在のドメインはログイン許可ドメインではありません。',
          zh: '当前域名未获登录授权。',
          fr: 'Ce domaine n’est pas autorisé pour la connexion.',
          pt: 'Este domínio não está autorizado para login.',
        );
      case 'operation-not-allowed':
        return _t(
          ko: '현재 로그인 방식이 활성화되어 있지 않습니다.',
          en: 'This sign-in method is not enabled.',
          ja: 'このログイン方法は有効になっていません。',
          zh: '此登录方式尚未启用。',
          fr: 'Cette méthode de connexion n’est pas activée.',
          pt: 'Este método de login não está ativado.',
        );
      case 'email-already-in-use':
        return _t(
          ko: '이미 가입되어 있습니다.',
          en: 'This account is already registered.',
          ja: 'すでに登録されています。',
          zh: '该账号已注册。',
          fr: 'Ce compte est déjà inscrit.',
          pt: 'Esta conta já está cadastrada.',
        );
      case 'weak-password':
        return _t(
          ko: '비밀번호는 6자 이상 입력해 주세요.',
          en: 'Password must be at least 6 characters.',
          ja: 'パスワードは6文字以上で入力してください。',
          zh: '密码至少需要6个字符。',
          fr: 'Le mot de passe doit contenir au moins 6 caractères.',
          pt: 'A senha deve ter pelo menos 6 caracteres.',
        );
      case 'invalid-email':
        return _t(
          ko: '아이디가 잘못 입력되었습니다.',
          en: 'The ID (email) is invalid.',
          ja: 'ID（メール）の入力が正しくありません。',
          zh: '账号（电子邮箱）输入不正确。',
          fr: 'L’identifiant (e-mail) est incorrect.',
          pt: 'O ID (e-mail) foi digitado incorretamente.',
        );
      case 'user-not-found':
        return _t(
          ko: '없는 아이디입니다.',
          en: 'This ID does not exist.',
          ja: '存在しないIDです。',
          zh: '该账号不存在。',
          fr: 'Cet identifiant n’existe pas.',
          pt: 'Este ID não existe.',
        );
      case 'wrong-password':
        return _t(
          ko: '비밀번호가 틀립니다.',
          en: 'The password is incorrect.',
          ja: 'パスワードが違います。',
          zh: '密码错误。',
          fr: 'Le mot de passe est incorrect.',
          pt: 'A senha está incorreta.',
        );
      case 'invalid-credential':
        return _t(
          ko: '아이디 또는 비밀번호가 틀립니다.',
          en: 'The ID or password is incorrect.',
          ja: 'IDまたはパスワードが違います。',
          zh: '账号或密码错误。',
          fr: 'L’identifiant ou le mot de passe est incorrect.',
          pt: 'O ID ou a senha está incorreto.',
        );
      case 'network-request-failed':
        return _t(
          ko: '네트워크 연결을 확인해 주세요.',
          en: 'Check your network connection.',
          ja: 'ネットワーク接続を確認してください。',
          zh: '请检查网络连接。',
          fr: 'Vérifiez votre connexion réseau.',
          pt: 'Verifique sua conexão de rede.',
        );
      case 'too-many-requests':
        return _t(
          ko: '요청이 너무 많습니다. 잠시 후 다시 시도해 주세요.',
          en: 'Too many attempts. Try again later.',
          ja: '試行回数が多すぎます。しばらくしてから再試行してください。',
          zh: '尝试次数过多，请稍后再试。',
          fr: 'Trop de tentatives. Réessayez plus tard.',
          pt: 'Muitas tentativas. Tente novamente mais tarde.',
        );
      case 'account-exists-with-different-credential':
        return _t(
          ko: '이미 가입되어 있습니다. 기존 로그인 방식을 이용해 주세요.',
          en:
              'This account is already registered. Use the original sign-in method.',
          ja: 'すでに登録されています。以前のログイン方法をご利用ください。',
          zh: '该账号已注册，请使用原来的登录方式。',
          fr:
              'Ce compte est déjà inscrit. Utilisez la méthode de connexion d’origine.',
          pt: 'Esta conta já está cadastrada. Use o método de login original.',
        );
      case 'credential-already-in-use':
        return _t(
          ko: '이미 가입되어 있습니다.',
          en: 'This account is already registered.',
          ja: 'すでに登録されています。',
          zh: '该账号已注册。',
          fr: 'Ce compte est déjà inscrit.',
          pt: 'Esta conta já está cadastrada.',
        );
      case 'user-disabled':
        return _t(
          ko: '사용이 중지된 계정입니다. 관리자에게 문의해 주세요.',
          en: 'This account is disabled. Contact the administrator.',
          ja: '利用停止中のアカウントです。管理者にお問い合わせください。',
          zh: '该账号已停用，请联系管理员。',
          fr: 'Ce compte est désactivé. Contactez l’administrateur.',
          pt: 'Esta conta está desativada. Entre em contato com o administrador.',
        );
      default:
        return _t(
          ko: '인증 처리 중 오류가 발생했습니다.',
          en: 'An authentication error occurred.',
          ja: '認証処理中にエラーが発生しました。',
          zh: '认证过程中发生错误。',
          fr: 'Une erreur d’authentification est survenue.',
          pt: 'Ocorreu um erro de autenticação.',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: _purple.withValues(alpha: 0.55)),
                  boxShadow: [
                    BoxShadow(
                      color: _purple.withValues(alpha: 0.20),
                      blurRadius: 32,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // 기존 로고 영역 유지
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _lime, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: _purple.withValues(alpha: 0.45),
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
                      Text(
                        _t(
                          ko: '계정에 로그인하세요',
                          en: 'Sign in to your account',
                          ja: 'アカウントにログイン',
                          zh: '登录您的账号',
                          fr: 'Connectez-vous à votre compte',
                          pt: 'Entre na sua conta',
                        ),
                        style: TextStyle(color: Colors.white60),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          label: _t(
                            ko: '이메일',
                            en: 'Email',
                            ja: 'メール',
                            zh: '电子邮箱',
                            fr: 'E-mail',
                            pt: 'E-mail',
                          ),
                          icon: Icons.email_outlined,
                        ),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _hidePassword,
                        autofillHints: const [AutofillHints.password],
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          label: _t(
                            ko: '비밀번호',
                            en: 'Password',
                            ja: 'パスワード',
                            zh: '密码',
                            fr: 'Mot de passe',
                            pt: 'Senha',
                          ),
                          icon: Icons.lock_outline,
                          suffix: IconButton(
                            onPressed: () {
                              setState(() {
                                _hidePassword = !_hidePassword;
                              });
                            },
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if ((value ?? '').isEmpty) {
                            return _t(
                              ko: '비밀번호를 입력해 주세요.',
                              en: 'Enter your password.',
                              ja: 'パスワードを入力してください。',
                              zh: '请输入密码。',
                              fr: 'Saisissez votre mot de passe.',
                              pt: 'Digite sua senha.',
                            );
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _signInWithEmail(),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 2,
                        runSpacing: 2,
                        children: [
                          TextButton(
                            onPressed: _isLoading ? null : _showFindId,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.white70,
                            ),
                            child: Text(
                              _t(
                                ko: '아이디 찾기',
                                en: 'Find ID',
                                ja: 'IDを探す',
                                zh: '找回账号',
                                fr: 'Retrouver l’identifiant',
                                pt: 'Encontrar ID',
                              ),
                            ),
                          ),
                          const Text(
                            '·',
                            style: TextStyle(color: Colors.white30),
                          ),
                          TextButton(
                            onPressed: _isLoading ? null : _sendPasswordReset,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.white70,
                            ),
                            child: Text(
                              _t(
                                ko: '비밀번호 찾기',
                                en: 'Forgot password',
                                ja: 'パスワードを探す',
                                zh: '忘记密码',
                                fr: 'Mot de passe oublié',
                                pt: 'Esqueci a senha',
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_message != null) ...[
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
                            _message!,
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
                          onPressed: _isLoading ? null : _signInWithEmail,
                          style: FilledButton.styleFrom(
                            backgroundColor: _purple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                  : Text(
                                    _t(
                                      ko: '이메일 로그인',
                                      en: 'Email Login',
                                      ja: 'メールログイン',
                                      zh: '邮箱登录',
                                      fr: 'Connexion par e-mail',
                                      pt: 'Login por e-mail',
                                    ),
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
                          onPressed: _isLoading ? null : _signUpWithEmail,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _lime,
                            side: const BorderSide(color: _lime, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.person_add_alt_1_outlined),
                          label: Text(
                            _t(
                              ko: '이메일 회원가입',
                              en: 'Email Sign Up',
                              ja: 'メール会員登録',
                              zh: '邮箱注册',
                              fr: 'Inscription par e-mail',
                              pt: 'Cadastro por e-mail',
                            ),
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white24)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              _t(
                                ko: '또는',
                                en: 'OR',
                                ja: 'または',
                                zh: '或',
                                fr: 'OU',
                                pt: 'OU',
                              ),
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
                          onPressed: _isLoading ? null : _signInWithGoogle,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _googleBackground,
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: _googleBorder,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Text(
                            'G',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          label: Text(
                            _t(
                              ko: 'Google로 계속하기',
                              en: 'Continue with Google',
                              ja: 'Googleで続行',
                              zh: '使用 Google 继续',
                              fr: 'Continuer avec Google',
                              pt: 'Continuar com Google',
                            ),
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _signInWithPhone,
                        icon: const Icon(Icons.sms_outlined),
                        label: Text(_t(
                          ko: '휴대폰 문자 인증으로 로그인',
                          en: 'Sign in with SMS',
                          ja: 'SMS認証でログイン',
                          zh: '通过短信登录',
                          fr: 'Connexion par SMS',
                          pt: 'Entrar por SMS',
                        )),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white70),
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _t(
                          ko: '기존 이메일·Google 사용자는 먼저 원래 계정으로 로그인한 뒤 설정에서 전화번호를 연결하세요.',
                          en: 'Existing email or Google users: sign in to your original account first, then link your phone in Settings.',
                          ja: '既存のメール・Googleユーザーは、先に元のアカウントでログインし、設定で電話番号を連携してください。',
                          zh: '现有邮箱或 Google 用户请先登录原账户，再到设置中绑定手机号。',
                          fr: 'Connectez-vous d’abord avec votre compte e-mail ou Google, puis associez le téléphone dans les paramètres.',
                          pt: 'Entre primeiro na conta de e-mail ou Google e vincule o telefone nas configurações.',
                        ),
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      if (kIsWeb) ...[
                        const SizedBox(height: 14),
                        Text(
                          _t(
                            ko: 'Google 로그인 창이 뜨지 않으면 브라우저의 팝업 차단을 해제해 주세요.',
                            en:
                                'If the Google sign-in window does not appear, allow pop-ups in your browser.',
                            ja: 'Googleログイン画面が表示されない場合は、ブラウザのポップアップを許可してください。',
                            zh: '如果 Google 登录窗口未出现，请允许浏览器弹出窗口。',
                            fr:
                                'Si la fenêtre Google ne s’affiche pas, autorisez les fenêtres contextuelles dans le navigateur.',
                            pt:
                                'Se a janela do Google não aparecer, permita pop-ups no navegador.',
                          ),
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

  static InputDecoration _inputDecoration({
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
        borderSide: const BorderSide(color: _purple, width: 1.6),
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
