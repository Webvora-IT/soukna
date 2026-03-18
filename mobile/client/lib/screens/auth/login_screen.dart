import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _googleLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final success = await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
      if (!mounted) return;
      if (success) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceAll('ApiException', '').replaceAll('Exception:', '').trim());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _googleLoading = true);
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) { setState(() => _googleLoading = false); return; }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseToken = await userCred.user?.getIdToken();

      // Exchange Firebase token for SOUKNA JWT
      final res = await ApiService.post(
        '/auth/firebase',
        {
          'firebaseToken': firebaseToken,
          'name': googleUser.displayName ?? googleUser.email.split('@')[0],
          'email': googleUser.email,
          'avatar': googleUser.photoUrl,
        },
        auth: false,
      );

      if (!mounted) return;
      final data = res['data'] as Map<String, dynamic>;
      context.read<AuthProvider>().setUser(data['user'], data['token']);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      _showError('Connexion Google échouée. Réessayez.');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.cairo()),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 16),
              Text('SOUKNA', style: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.bold)),
              Text('سوقنا', style: GoogleFonts.cairo(fontSize: 20, color: const Color(0xFFF59E0B))),
              const SizedBox(height: 40),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.cairo(),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: GoogleFonts.cairo(),
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: (v) => v?.isEmpty == true ? 'Email requis' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      style: GoogleFonts.cairo(),
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        labelStyle: GoogleFonts.cairo(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => v?.isEmpty == true ? 'Mot de passe requis' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Se connecter', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),

                    const SizedBox(height: 20),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('ou continuer avec', style: GoogleFonts.cairo(color: Colors.grey, fontSize: 13)),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Google Sign-In button
                    OutlinedButton.icon(
                      onPressed: _googleLoading ? null : _signInWithGoogle,
                      icon: _googleLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Image.asset('assets/icons/google.png', width: 20, height: 20,
                              errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 22, color: Color(0xFF4285F4))),
                      label: Text('Continuer avec Google', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Phone Sign-In button
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/phone-auth'),
                      icon: const Icon(Icons.phone_outlined, color: Color(0xFF10B981)),
                      label: Text('Continuer avec le téléphone', style: GoogleFonts.cairo(fontWeight: FontWeight.w600, color: const Color(0xFF10B981))),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF10B981)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                      child: Text.rich(
                        TextSpan(
                          text: "Pas encore de compte ? ",
                          style: GoogleFonts.cairo(color: Colors.grey[600]),
                          children: [
                            TextSpan(text: "S'inscrire", style: GoogleFonts.cairo(color: const Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
