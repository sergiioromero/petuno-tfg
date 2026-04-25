import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/main_navigation.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_button.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _birthDateController = TextEditingController();
  bool _obscurePassword = true;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryPink,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text =
            '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.year}';
      });
    }
  }

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              name: _nameController.text.trim(),
            ),
          );
    }
  }

  void _onGoogleSignUp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google Sign-In próximamente')),
    );
  }

  void _onAppleSignUp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Apple Sign-In próximamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Registro exitoso - navegar al home
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
                        'Crear cuenta',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111111),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Únete a la comunidad Petuno 🐾',
                        style: TextStyle(fontSize: 15, color: Color(0xFF888888)),
                      ),

                      const SizedBox(height: 32),

                      // Registro social
                      Row(
                        children: [
                          SocialButton(
                            label: 'Google',
                            icon: Icons.g_mobiledata_rounded,
                            iconColor: const Color(0xFFDB4437),
                            onTap: isLoading ? () {} : _onGoogleSignUp,
                          ),
                          const SizedBox(width: 12),
                          SocialButton(
                            label: 'Apple',
                            icon: Icons.apple,
                            iconColor: Colors.black,
                            onTap: isLoading ? () {} : _onAppleSignUp,
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
                              'o regístrate con email',
                              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                            ),
                          ),
                          const Expanded(child: Divider(color: Color(0xFFEEEEEE))),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Campo Nombre
                      AuthTextField(
                        label: 'Nombre',
                        hint: 'Tu nombre',
                        prefixIcon: Icons.person_outline,
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Introduce tu nombre' : null,
                      ),

                      const SizedBox(height: 20),

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
                        hint: 'Mínimo 6 caracteres',
                        prefixIcon: Icons.lock_outline,
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Introduce una contraseña';
                          if (v.length < 6) return 'Mínimo 6 caracteres';
                          return null;
                        },
                        suffixWidget: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Campo Fecha de nacimiento
                      AuthTextField(
                        label: 'Fecha de nacimiento',
                        hint: 'DD/MM/AAAA',
                        prefixIcon: Icons.cake_outlined,
                        controller: _birthDateController,
                        readOnly: true,
                        onTap: _pickDate,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Selecciona tu fecha de nacimiento' : null,
                      ),

                      const SizedBox(height: 32),

                      // Botón registrarse
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _onRegister,
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
                                  'Crear cuenta',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Enlace login
                      Center(
                        child: GestureDetector(
                          onTap: isLoading
                              ? null
                              : () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                  );
                                },
                          child: RichText(
                            text: TextSpan(
                              text: '¿Ya tienes cuenta? ',
                              style: const TextStyle(fontSize: 14, color: Color(0xFF888888)),
                              children: [
                                TextSpan(
                                  text: 'Inicia sesión',
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