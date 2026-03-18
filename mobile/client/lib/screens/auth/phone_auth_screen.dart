import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _codeSent = false;
  bool _loading = false;
  String? _verificationId;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _error = 'Entrez votre numéro de téléphone');
      return;
    }

    setState(() { _loading = true; _error = null; });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification on Android
        await _signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _error = e.message ?? 'Erreur de vérification';
          _loading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _codeSent = true;
          _loading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> _verifyCode() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Entrez le code à 6 chiffres');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );
      await _signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.code == 'invalid-verification-code'
            ? 'Code incorrect. Vérifiez et réessayez.'
            : e.message ?? 'Erreur de vérification';
        _loading = false;
      });
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseToken = await userCredential.user?.getIdToken();

      // Exchange Firebase token for SOUKNA JWT
      final res = await ApiService.post(
        '/auth/firebase',
        {'firebaseToken': firebaseToken, 'phone': _phoneController.text.trim()},
        auth: false,
      );

      if (!mounted) return;
      final { 'token': token, 'user': user } = res['data'] as Map<String, dynamic>;
      context.read<AuthProvider>().setUser(user, token);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _error = 'Connexion échouée. Vérifiez votre numéro.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      appBar: AppBar(
        title: Text('Connexion par téléphone', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),

            // Icon
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone_android, size: 40, color: Color(0xFFF59E0B)),
            ),

            Text(
              _codeSent ? 'Entrez le code SMS' : 'Votre numéro de téléphone',
              style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _codeSent
                  ? 'Un code à 6 chiffres a été envoyé au ${_phoneController.text}'
                  : 'Entrez votre numéro avec l\'indicatif pays (ex: +222 XX XX XX XX)',
              style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(_error!, style: GoogleFonts.cairo(color: Colors.red[700], fontSize: 13)),
              ),
              const SizedBox(height: 16),
            ],

            if (!_codeSent) ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.cairo(fontSize: 18),
                decoration: InputDecoration(
                  hintText: '+222 XX XX XX XX',
                  hintStyle: GoogleFonts.cairo(color: Colors.grey),
                  prefixIcon: const Icon(Icons.phone, color: Color(0xFFF59E0B)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _sendCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Envoyer le code', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ] else ...[
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _otpController,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 56,
                  fieldWidth: 44,
                  activeFillColor: Colors.white,
                  inactiveFillColor: Colors.white,
                  selectedFillColor: const Color(0xFFFFFBF0),
                  activeColor: const Color(0xFFF59E0B),
                  inactiveColor: const Color(0xFFE5E7EB),
                  selectedColor: const Color(0xFFF59E0B),
                ),
                enableActiveFill: true,
                onCompleted: (_) => _verifyCode(),
                onChanged: (_) {},
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Vérifier le code', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loading ? null : () => setState(() { _codeSent = false; _error = null; }),
                child: Text('Modifier le numéro', style: GoogleFonts.cairo(color: const Color(0xFFF59E0B))),
              ),
              TextButton(
                onPressed: _loading ? null : _sendCode,
                child: Text('Renvoyer le code', style: GoogleFonts.cairo(color: Colors.grey[600])),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
