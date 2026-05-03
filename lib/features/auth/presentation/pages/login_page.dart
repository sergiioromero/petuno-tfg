import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/main_navigation.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_button.dart';
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

  void _onGoogleLogin() {
    // TODO: Implementar Google Sign-In
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google Sign-In próximamente')),
    );
  }

  void _onAppleLogin() {
    // TODO: Implementar Apple Sign-In
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Apple Sign-In próximamente')),
    );
  }

  void _onForgotPassword() {
    // TODO: Implementar recuperación de contraseña
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recuperación de contraseña próximamente')),
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
          } else if (state is AuthError) {
            // Mostrar error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
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

                      const SizedBox(height: 32),

                      // Login social
                      Row(
                        children: [
                          SocialButton(
                            label: 'Google',
                            icon: Icons.g_mobiledata_rounded,
                            iconColor: const Color(0xFFDB4437),
                            onTap: isLoading ? () {} : _onGoogleLogin,
                          ),
                          const SizedBox(width: 12),
                          SocialButton(
                            label: 'Apple',
                            icon: Icons.apple,
                            iconColor: Colors.black,
                            onTap: isLoading ? () {} : _onAppleLogin,
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

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