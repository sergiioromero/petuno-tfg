import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/user.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_event.dart';
import '../bloc/profile/profile_state.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late List<String> _interests;
  final TextEditingController _interestController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _ageController = TextEditingController(text: widget.user.age.toString());
    _bioController = TextEditingController(text: widget.user.bio);
    _locationController = TextEditingController(text: widget.user.location);
    _interests = List.from(widget.user.interests);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedUser = widget.user.copyWith(
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        bio: _bioController.text.trim(),
        location: _locationController.text.trim(),
        interests: _interests,
      );

      context.read<ProfileBloc>().add(UpdateProfile(updatedUser));
      Navigator.pop(context);
    }
  }

  void _addInterest() {
    if (_interestController.text.trim().isNotEmpty) {
      setState(() {
        _interests.add(_interestController.text.trim());
        _interestController.clear();
      });
    }
  }

  void _removeInterest(int index) {
    setState(() {
      _interests.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.cardColor(context),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: AppTheme.textPrimary(context)),
        ),
        title: Text(
          'Editar perfil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              'Guardar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryPink,
              ),
            ),
          ),
        ],
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Avatar
              Center(
                child: GestureDetector(
                  onTap: () {
                    // TODO: cambiar avatar
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryPink,
                              AppTheme.primaryPink.withOpacity(0.6),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.user.avatarEmoji,
                            style: const TextStyle(fontSize: 45),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPink,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Nombre
              _buildTextField(
                label: 'Nombre',
                controller: _nameController,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Introduce tu nombre' : null,
              ),

              const SizedBox(height: 20),

              // Edad
              _buildTextField(
                label: 'Edad',
                controller: _ageController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Introduce tu edad';
                  if (int.tryParse(v) == null) return 'Edad no válida';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Ubicación
              _buildTextField(
                label: 'Ubicación',
                controller: _locationController,
                prefixIcon: Icons.location_on_outlined,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Introduce tu ubicación' : null,
              ),

              const SizedBox(height: 20),

              // Bio
              _buildTextField(
                label: 'Bio',
                controller: _bioController,
                maxLines: 4,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Escribe algo sobre ti' : null,
              ),

              const SizedBox(height: 24),

              // Intereses
              Text(
                'Intereses',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary(context),
                ),
              ),

              const SizedBox(height: 12),

              // Lista de intereses
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._interests.asMap().entries.map(
                        (entry) => Chip(
                          label: Text(entry.value),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => _removeInterest(entry.key),
                          backgroundColor: AppTheme.primaryPink.withOpacity(0.1),
                          side: BorderSide(
                            color: AppTheme.primaryPink.withOpacity(0.3),
                          ),
                          labelStyle: TextStyle(
                            color: AppTheme.primaryPink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                ],
              ),

              const SizedBox(height: 12),

              // Añadir interés
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _interestController,
                      decoration: InputDecoration(
                        hintText: 'Añadir interés',
                        filled: true,
                        fillColor: AppTheme.inputBackground(context),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppTheme.borderColor(context),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppTheme.borderColor(context),
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _addInterest(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addInterest,
                    icon: Icon(Icons.add_circle, color: AppTheme.primaryPink),
                    iconSize: 32,
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.inputBackground(context),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppTheme.primaryPink, size: 20)
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppTheme.borderColor(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppTheme.borderColor(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppTheme.primaryPink, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}