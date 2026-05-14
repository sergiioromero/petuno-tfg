import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/main_navigation.dart';
import '../../../../firebase_options.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  void _onForgotPassword() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showPasswordResetDialog();
    } else {
      _showResetOptionsDialog(email);
    }
  }

  void _showResetOptionsDialog(String email) {
    showDialog(
      context: context,
      builder: (ctx) => _ResetOptionsDialog(email: email, bloc: context.read<AuthBloc>()),
    );
  }

  void _showPasswordResetDialog() {
    final controller = TextEditingController(text: _emailController.text.trim());
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_reset_rounded,
                    color: AppTheme.primaryPink, size: 28),
              ),
              const SizedBox(height: 20),
              const Text(
                'Recuperar contraseña',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Introduce tu email para recibir un enlace de recuperación',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'tucorreo@email.com',
                  prefixIcon:
                      const Icon(Icons.email_outlined, color: Color(0xFF888888)),
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppTheme.primaryPink, width: 1.5),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final email = controller.text.trim();
                    if (email.isNotEmpty && email.contains('@')) {
                      Navigator.pop(ctx);
                      context
                          .read<AuthBloc>()
                          .add(AuthPasswordResetRequested(email: email));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Enviar enlace',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancelar',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetResultDialog(String email) {
    showDialog(
      context: context,
      builder: (ctx) => _ResetResultDialog(email: email),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Login exitoso - navegar al home
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainNavigation()),
              (route) => false,
            );
          } else if (state is AuthPasswordResetSent) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            _showResetResultDialog(state.email);
          } else if (state is AuthError) {
            AppSnackBar.show(context, state.message, type: SnackBarType.error);
          }
        },
        child: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Botón volver
                      IconButton(
                        onPressed: isLoading ? null : () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.black, size: 26),
                        padding: EdgeInsets.zero,
                      ),

                      const SizedBox(height: 24),

                      // Cabecera
                      const Text(
                        'Bienvenido de nuevo',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111111),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Inicia sesión para continuar 🐾',
                        style: TextStyle(fontSize: 15, color: Color(0xFF888888)),
                      ),

                      const SizedBox(height: 24),

                      // Google Sign-In
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => context
                                  .read<AuthBloc>()
                                  .add(const AuthGoogleSignInRequested()),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF333333),
                            side: const BorderSide(color: Color(0xFFDDDDDD)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Center(
                                  child: Text(
                                    'G',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF4285F4),
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Continuar con Google',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Separador "o"
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Color(0xFFEEEEEE))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'o inicia sesión con email',
                              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                            ),
                          ),
                          const Expanded(child: Divider(color: Color(0xFFEEEEEE))),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Campo Email
                      AuthTextField(
                        label: 'Email',
                        hint: 'tucorreo@email.com',
                        prefixIcon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Introduce tu email';
                          if (!v.contains('@')) return 'Email no válido';
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Campo Contraseña
                      AuthTextField(
                        label: 'Contraseña',
                        hint: 'Tu contraseña',
                        prefixIcon: Icons.lock_outline,
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Introduce tu contraseña';
                          if (v.length < 6) return 'Mínimo 6 caracteres';
                          return null;
                        },
                        suffixWidget: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ¿Olvidaste tu contraseña?
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: isLoading ? null : _onForgotPassword,
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryPink,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Botón iniciar sesión
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _onLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPink,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 4,
                            shadowColor: AppTheme.primaryPink.withOpacity(0.4),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Iniciar sesión',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Enlace registro
                      Center(
                        child: GestureDetector(
                          onTap: isLoading
                              ? null
                              : () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterPage(),
                                    ),
                                  );
                                },
                          child: RichText(
                            text: TextSpan(
                              text: '¿No tienes cuenta? ',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF888888),
                              ),
                              children: [
                                TextSpan(
                                  text: 'Regístrate',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryPink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ResetOptionsDialog extends StatelessWidget {
  final String email;
  final AuthBloc bloc;
  const _ResetOptionsDialog({required this.email, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryPink.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_reset_rounded,
                  color: AppTheme.primaryPink, size: 28),
            ),
            const SizedBox(height: 20),
            const Text(
              'Recuperar contraseña',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Se enviará un enlace de recuperación a:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  bloc.add(AuthPasswordResetRequested(email: email));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text('Enviar enlace',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResetResultDialog extends StatelessWidget {
  final String email;
  const _ResetResultDialog({required this.email});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 28),
            ),
            const SizedBox(height: 20),
            const Text(
              'Email enviado',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Revisa tu bandeja de entrada.\nSi no aparece, comprueba la carpeta de spam.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (ctx) => _DirectLinkDialog(email: email),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryPink,
                  side: const BorderSide(color: AppTheme.primaryPink),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'No recibí el email',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text('Entendido',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DirectLinkDialog extends StatefulWidget {
  final String email;
  const _DirectLinkDialog({required this.email});

  @override
  State<_DirectLinkDialog> createState() => _DirectLinkDialogState();
}

class _DirectLinkDialogState extends State<_DirectLinkDialog> {
  bool _loading = false;
  String? _link;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _link != null
                    ? Colors.green.withOpacity(0.1)
                    : AppTheme.primaryPink.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _link != null
                    ? Icons.check_circle
                    : _error != null
                        ? Icons.error_outline
                        : Icons.link_rounded,
                color: _link != null
                    ? Colors.green
                    : _error != null
                        ? Colors.red
                        : AppTheme.primaryPink,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _link != null
                  ? 'Enlace generado'
                  : _error != null
                      ? 'Error'
                      : 'Obtener enlace directo',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            if (_link != null) ...[
              Text(
                'Copia el enlace y pégalo en tu navegador para restablecer la contraseña.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _link!,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ] else if (_error != null) ...[
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.red),
              ),
            ] else ...[
              Text(
                'Generaremos un enlace para restablecer tu contraseña.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 24),
            if (_link != null)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _link!));
                    AppSnackBar.show(
                      context,
                      'Enlace copiado al portapapeles',
                      type: SnackBarType.success,
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  label: const Text('Copiar enlace',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            if (_error != null)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _link = null;
                    });
                    _generateLink();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Reintentar',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            if (_link == null && _error == null)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _generateLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Generar enlace',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateLink() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final apiKey = DefaultFirebaseOptions.currentPlatform.apiKey;
      final url = 'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=$apiKey';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requestType': 'PASSWORD_RESET',
          'email': widget.email,
          'returnOobLink': true,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['oobLink'] != null) {
        setState(() => _link = data['oobLink']);
      } else {
        final error = data['error']?['message'] ?? 'EMAIL_NOT_FOUND';
        if (error == 'EMAIL_NOT_FOUND') {
          setState(() => _error = 'Este email no está registrado');
        } else {
          setState(() => _error = 'Error al generar el enlace. Intenta de nuevo.');
        }
      }
    } catch (e) {
      setState(() => _error = 'Error de conexión. Verifica tu internet.');
    } finally {
      setState(() => _loading = false);
    }
  }
}