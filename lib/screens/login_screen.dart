import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _loading  = false;
  String? _error;

  // Login
  final _emailCtrl    = TextEditingController(text: 'carlos@uni.edu');
  final _passCtrl     = TextEditingController(text: '123456');

  // Registro
  final _regNombreCtrl = TextEditingController();
  final _regEmailCtrl  = TextEditingController();
  final _regPassCtrl   = TextEditingController();
  String _regRol       = 'estudiante';

  @override
  void dispose() {
    _emailCtrl.dispose(); _passCtrl.dispose();
    _regNombreCtrl.dispose(); _regEmailCtrl.dispose(); _regPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 600)); // Simula latencia

    final err = context.read<AppProvider>().login(
      _emailCtrl.text,
      _passCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) {
      setState(() => _error = err);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  Future<void> _doRegistro() async {
    if (_regNombreCtrl.text.trim().isEmpty ||
        _regEmailCtrl.text.trim().isEmpty ||
        _regPassCtrl.text.isEmpty) {
      setState(() => _error = 'Completa todos los campos.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() { _loading = false; _isLogin = true; });
    _emailCtrl.text = _regEmailCtrl.text;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cuenta creada. ¡Inicia sesión!'),
        backgroundColor: AppTheme.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2A8A), Color(0xFF1A47D6), Color(0xFF2D6BE4)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 420),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 60,
                      offset: const Offset(0, 20),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.spaceMono(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.accent),
                        children: [
                          const TextSpan(text: 'Tutor'),
                          TextSpan(text: 'Match', style: GoogleFonts.spaceMono(color: AppTheme.muted, fontWeight: FontWeight.w400)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Encuentra tu tutor ideal en minutos',
                        style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.muted)),
                    const SizedBox(height: 24),

                    // Tabs
                    _AuthTabs(
                      isLogin: _isLogin,
                      onSwitch: (v) => setState(() { _isLogin = v; _error = null; }),
                    ),
                    const SizedBox(height: 20),

                    // Error
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.redL,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFF5C6C6)),
                        ),
                        child: Text(_error!, style: GoogleFonts.nunito(color: AppTheme.red, fontSize: 13.5, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Formulario
                    if (_isLogin) _LoginForm(emailCtrl: _emailCtrl, passCtrl: _passCtrl)
                    else _RegistroForm(
                      nombreCtrl: _regNombreCtrl,
                      emailCtrl:  _regEmailCtrl,
                      passCtrl:   _regPassCtrl,
                      rol: _regRol,
                      onRolChange: (v) => setState(() => _regRol = v!),
                    ),
                    const SizedBox(height: 6),

                    // Hint demo
                    if (_isLogin) ...[
                      Text(
                        'Demo: carlos@uni.edu / 123456',
                        style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.muted),
                      ),
                      const SizedBox(height: 16),
                    ] else
                      const SizedBox(height: 16),

                    // Botón
                    ElevatedButton(
                      onPressed: _loading ? null : (_isLogin ? _doLogin : _doRegistro),
                      child: _loading
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(_isLogin ? 'Entrar' : 'Crear cuenta'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tabs ─────────────────────────────────────────────────────────────────
class _AuthTabs extends StatelessWidget {
  final bool isLogin;
  final ValueChanged<bool> onSwitch;
  const _AuthTabs({required this.isLogin, required this.onSwitch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          _tab('Iniciar sesión', isLogin, () => onSwitch(true)),
          _tab('Crear cuenta', !isLogin, () => onSwitch(false)),
        ],
      ),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppTheme.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)] : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: active ? AppTheme.accent : AppTheme.muted,
          ),
        ),
      ),
    ),
  );
}

// ── Formulario Login ──────────────────────────────────────────────────────
class _LoginForm extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  const _LoginForm({required this.emailCtrl, required this.passCtrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Correo electrónico'),
        const SizedBox(height: 6),
        TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'correo@ejemplo.com')),
        const SizedBox(height: 14),
        _Label('Contraseña'),
        const SizedBox(height: 6),
        TextField(controller: passCtrl, obscureText: true,
            decoration: const InputDecoration(hintText: '••••••••')),
        const SizedBox(height: 6),
      ],
    );
  }
}

// ── Formulario Registro ───────────────────────────────────────────────────
class _RegistroForm extends StatelessWidget {
  final TextEditingController nombreCtrl, emailCtrl, passCtrl;
  final String rol;
  final ValueChanged<String?> onRolChange;
  const _RegistroForm({
    required this.nombreCtrl, required this.emailCtrl,
    required this.passCtrl, required this.rol, required this.onRolChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Nombre completo'),
        const SizedBox(height: 6),
        TextField(controller: nombreCtrl, decoration: const InputDecoration(hintText: 'Tu nombre')),
        const SizedBox(height: 14),
        _Label('Correo electrónico'),
        const SizedBox(height: 6),
        TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'correo@ejemplo.com')),
        const SizedBox(height: 14),
        _Label('Contraseña'),
        const SizedBox(height: 6),
        TextField(controller: passCtrl, obscureText: true,
            decoration: const InputDecoration(hintText: 'Mínimo 6 caracteres')),
        const SizedBox(height: 14),
        _Label('Soy...'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: rol,
          items: const [
            DropdownMenuItem(value: 'estudiante', child: Text('Estudiante')),
            DropdownMenuItem(value: 'tutor',      child: Text('Tutor')),
          ],
          onChanged: onRolChange,
          decoration: InputDecoration(
            filled: true, fillColor: AppTheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border, width: 1.5)),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: GoogleFonts.nunito(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.muted, letterSpacing: 0.5),
  );
}
