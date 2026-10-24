import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/orqube_i18n.dart';

/// SMS is a separate Firebase provider. Existing email/Google users should
/// link their phone after signing in to retain their existing UID and data.
class PhoneSignInDialog extends StatefulWidget {
  const PhoneSignInDialog({super.key, this.linkToCurrentUser = false});

  final bool linkToCurrentUser;

  @override
  State<PhoneSignInDialog> createState() => _PhoneSignInDialogState();
}

class _PhoneSignInDialogState extends State<PhoneSignInDialog> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  ConfirmationResult? _webConfirmation;
  String? _verificationId;
  bool _busy = false;
  String? _originalUid;
  String? _error;
  RecaptchaVerifier? _recaptcha;
  int? _resendToken;
  int _sendGeneration = 0;

  void _clearRecaptcha() {
    final verifier = _recaptcha;
    _recaptcha = null;
    try {
      verifier?.clear();
    } catch (error) {
      debugPrint('reCAPTCHA cleanup: $error');
    }
  }

  String _authError(FirebaseAuthException error) {
    switch (error.code) {
      case 'captcha-check-failed':
      case 'invalid-app-credential':
      case 'missing-app-credential':
        return 'reCAPTCHA 인증에 실패했습니다. 광고 차단기를 끄고 다시 시도하세요. 실제 SMS는 승인된 HTTPS 도메인에서 시험하세요.';
      case 'unauthorized-domain':
        return '현재 도메인이 승인되지 않았습니다. Firebase Authentication 승인 도메인 설정을 확인하세요.';
      case 'too-many-requests':
        return '요청이 너무 많습니다. 잠시 기다린 뒤 다시 시도하세요.';
      case 'quota-exceeded':
        return '문자 발송 할당량 또는 결제 설정을 확인해야 합니다.';
      case 'invalid-verification-code':
        return '인증번호가 틀렸습니다. 받은 6자리를 다시 입력하세요.';
      case 'session-expired':
      case 'invalid-verification-id':
        return '인증 시간이 만료되었습니다. 다시 보내기를 선택하세요.';
      default:
        return '${error.code}: ${error.message ?? "인증에 실패했습니다. 다시 시도하세요."}';
    }
  }

  bool get _ko => OrqubeI18n.normalize(OrqubeI18n.currentLanguage) == 'ko';
  String _label(String ko, String en) => _ko ? ko : en;

  @override
  void dispose() {
    _sendGeneration++;
    _clearRecaptcha();
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  String? _normalizedPhone() {
    final input = _phone.text.replaceAll(RegExp(r'[\s()-]'), '');
    if (RegExp(r'^01[016789]\d{7,8}$').hasMatch(input)) {
      return '+82${input.substring(1)}';
    }
    if (RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(input)) return input;
    return null;
  }

  Future<void> _send() async {
    if (_busy) return;
    if (kIsWeb &&
        (Uri.base.host == 'localhost' ||
            Uri.base.host == '127.0.0.1' ||
            Uri.base.host == '::1')) {
      setState(
        () =>
            _error =
                'localhost에서는 실제 SMS 인증을 진행하지 않습니다. 승인된 HTTPS 도메인에서 테스트해 주세요.',
      );
      return;
    }
    final number = _normalizedPhone();
    if (number == null) {
      setState(
        () =>
            _error = _label(
              '휴대폰 번호를 입력하세요. 한국 번호는 01012345678 형식입니다.',
              'Enter a valid phone number, such as +821012345678.',
            ),
      );
      return;
    }
    if (widget.linkToCurrentUser) {
      final current = FirebaseAuth.instance.currentUser;
      if (current == null ||
          current.isAnonymous ||
          !current.providerData.any(
            (provider) =>
                provider.providerId == 'password' ||
                provider.providerId == 'google.com',
          )) {
        setState(() => _error = '기존 이메일 또는 Google 계정으로 먼저 로그인해 주세요.');
        return;
      }
      _originalUid = current.uid;
    }
    final generation = ++_sendGeneration;
    _clearRecaptcha();
    _code.clear();
    setState(() {
      _busy = true;
      _error = null;
      _verificationId = null;
      _webConfirmation = null;
    });
    try {
      if (kIsWeb) {
        // Firebase displays reCAPTCHA when required by web phone auth.
        _recaptcha = RecaptchaVerifier(
          auth: FirebaseAuthPlatform.instance,
          // With no container, the SDK creates its default invisible challenge.
        );
        final confirmation = await FirebaseAuth.instance
            .signInWithPhoneNumber(number, _recaptcha)
            .timeout(const Duration(seconds: 90));
        if (!mounted || generation != _sendGeneration) return;
        setState(() => _webConfirmation = confirmation);
      } else {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: number,
          forceResendingToken: _resendToken,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (credential) async {
            if (!mounted || generation != _sendGeneration) return;
            try {
              final result = await _complete(credential);
              if (mounted) Navigator.of(context).pop(result);
            } on FirebaseAuthException catch (error) {
              if (mounted)
                setState(() {
                  _busy = false;
                  _error = _authError(error);
                });
            } catch (_) {
              if (mounted)
                setState(() {
                  _busy = false;
                  _error = '자동 인증에 실패했습니다. 인증번호를 입력하거나 다시 시도하세요.';
                });
            }
          },
          verificationFailed: (error) {
            if (!mounted || generation != _sendGeneration) return;
            if (mounted)
              setState(() {
                _busy = false;
                _error = _authError(error);
              });
          },
          codeSent: (id, resendToken) {
            if (!mounted || generation != _sendGeneration) return;
            if (mounted)
              setState(() {
                _verificationId = id;
                _resendToken = resendToken;
                _busy = false;
              });
          },
          codeAutoRetrievalTimeout: (id) {
            if (!mounted || generation != _sendGeneration) return;
            setState(() {
              _verificationId = id;
              _busy = false;
            });
          },
        );
      }
    } on TimeoutException {
      if (!mounted || generation != _sendGeneration) return;
      if (mounted)
        setState(
          () => _error = '인증 응답 시간이 초과되었습니다. 네트워크를 확인하고 문자 받기를 다시 선택하세요.',
        );
    } on FirebaseAuthException catch (error) {
      if (!mounted || generation != _sendGeneration) return;
      if (mounted)
        setState(() {
          _error = _authError(error);
          _busy = false;
        });
    } catch (_) {
      if (!mounted || generation != _sendGeneration) return;
      if (mounted)
        setState(() {
          _busy = false;
          _error = _label(
            '문자 발송에 실패했습니다. 잠시 후 다시 시도하세요.',
            'Could not send the SMS. Please try again.',
          );
        });
    } finally {
      if (generation == _sendGeneration) {
        _clearRecaptcha();
        if (mounted && kIsWeb) setState(() => _busy = false);
      }
    }
  }

  Future<UserCredential> _complete(PhoneAuthCredential credential) async {
    if (!widget.linkToCurrentUser) {
      return FirebaseAuth.instance.signInWithCredential(credential);
    }
    final current = FirebaseAuth.instance.currentUser;
    if (current == null || current.uid != _originalUid) {
      throw FirebaseAuthException(
        code: 'user-changed',
        message: '로그인 계정이 변경되었습니다. 기존 계정으로 다시 로그인해 주세요.',
      );
    }
    final result = await current.linkWithCredential(credential);
    if (result.user?.uid != _originalUid) {
      throw FirebaseAuthException(
        code: 'user-changed',
        message: '계정 연결을 확인할 수 없습니다. 다시 로그인해 주세요.',
      );
    }
    return result;
  }

  Future<void> _confirm() async {
    if (_busy || (_webConfirmation == null && _verificationId == null)) return;
    final code = _code.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(
        () => _error = _label('인증번호 6자리를 입력하세요.', 'Enter the 6-digit code.'),
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final UserCredential result;
      if (kIsWeb && !widget.linkToCurrentUser) {
        result = await _webConfirmation!.confirm(code);
      } else {
        final credential = PhoneAuthProvider.credential(
          verificationId:
              kIsWeb ? _webConfirmation!.verificationId : _verificationId!,
          smsCode: code,
        );
        result = await _complete(credential);
      }
      if (mounted) Navigator.of(context).pop(result);
    } on FirebaseAuthException catch (error) {
      if (mounted)
        setState(
          () =>
              _error =
                  error.code == 'credential-already-in-use'
                      ? '이 전화번호는 다른 계정에 연결되어 있습니다. 자동 병합하지 않았습니다. 고객 지원에 문의해 주세요.'
                      : _authError(error),
        );
      if (mounted &&
          (error.code == 'session-expired' ||
              error.code == 'invalid-verification-id')) {
        setState(() {
          _verificationId = null;
          _webConfirmation = null;
          _code.clear();
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = '인증 처리에 실패했습니다. 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sent = _webConfirmation != null || _verificationId != null;
    return AlertDialog(
      backgroundColor: const Color(0xFF101124),
      title: Text(
        widget.linkToCurrentUser
            ? '기존 계정에 휴대폰 연결'
            : _label('휴대폰 문자 로그인', 'SMS sign-in'),
        style: const TextStyle(color: Colors.white),
      ),
      scrollable: true,
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.linkToCurrentUser
                  ? '현재 로그인한 계정에 이 번호를 연결합니다. 연결 후 문자 로그인으로 같은 데이터를 이용할 수 있습니다.'
                  : _label(
                    '기존 이메일·Google 계정의 데이터는 별도 계정으로 로그인하면 연결되지 않습니다.',
                    'A separate phone sign-in does not carry over data from an existing email or Google account.',
                  ),
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            if (kIsWeb)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  Uri.base.host == 'localhost' || Uri.base.host == '127.0.0.1'
                      ? 'localhost: 화면 점검용입니다. 실제 문자 인증은 승인된 HTTPS 도메인에서 테스트하세요.'
                      : '문자 인증을 위해 전화번호가 Google/Firebase에 전달됩니다. 동의하시면 문자 받기를 선택하세요.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            const SizedBox(height: 14),
            TextField(
              controller: _phone,
              enabled: !_busy && !sent,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: _label(
                  '휴대폰 번호 (01012345678)',
                  'Phone (+country code)',
                ),
                labelStyle: const TextStyle(color: Colors.white70),
                border: const OutlineInputBorder(),
              ),
            ),
            if (sent) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _code,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: _label('문자로 받은 6자리', '6-digit SMS code'),
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(
            _label('취소', 'Cancel'),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        if (sent)
          TextButton(
            onPressed: _busy ? null : _send,
            child: Text(
              _label('다시 보내기', 'Resend'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        FilledButton(
          onPressed:
              _busy
                  ? null
                  : sent
                  ? _confirm
                  : _send,
          child: Text(
            _busy
                ? _label('처리 중…', 'Please wait…')
                : sent
                ? (widget.linkToCurrentUser
                    ? '인증하고 연결'
                    : _label('인증하고 로그인', 'Verify and sign in'))
                : _label('문자 받기', 'Send SMS'),
          ),
        ),
      ],
    );
  }
}
