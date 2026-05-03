import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petuno_app/core/services/cloudinary_service.dart';
import 'package:petuno_app/features/profile/presentation/widgets/image_picker_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/pet.dart';
import '../bloc/pet/pet_bloc.dart';
import '../bloc/pet/pet_event.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_state.dart';

class EditPetPage extends StatefulWidget {
  final Pet? pet; // null = crear nueva

  const EditPetPage({super.key, this.pet});

  @override
  State<EditPetPage> createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _ageController;
  late TextEditingController _personalityController;
  late String _selectedEmoji;
  late String _selectedBgColor;
  late List<String> _photos;

  final List<String> _animalEmojis = ['🐕', '🐈', '🐇', '🦜', '🐠', '🐹', '🦎'];
  final List<String> _bgColors = [
    '0xFFFFF3E0',
    '0xFFE8F5E9',
    '0xFFF3E5F5',
    '0xFFE3F2FD',
    '0xFFFCE4EC',
    '0xFFFFF8E1',
  ];

  @override
  void initState() {
    super.initState();
    final pet = widget.pet;
    _nameController = TextEditingController(text: pet?.name ?? '');
    _breedController = TextEditingController(text: pet?.breed ?? '');
    _ageController = TextEditingController(text: pet?.age ?? '');
    _personalityController =
        TextEditingController(text: pet?.personality ?? '');
    _selectedEmoji = pet?.emoji ?? _animalEmojis[0];
    _selectedBgColor = pet?.bgColor ?? _bgColors[0];
    _photos = pet?.photos ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _personalityController.dispose();
    super.dispose();
  }

  /// Obtiene el uid del usuario desde el ProfileBloc
  String? _getUid(BuildContext context) {
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      return profileState.user.id;
    }
    return null;
  }

  void _savePet() async {
    if (_formKey.currentState!.validate()) {
      final uid = _getUid(context);
      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: no se pudo obtener el usuario')),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CircularProgressIndicator()),
      );

      try {
        // Subir imágenes locales a Cloudinary, mantener las que ya son URL
        List<String> uploadedUrls = [];
        for (String photoPath in _photos) {
          if (photoPath.startsWith('http')) {
            uploadedUrls.add(photoPath);
          } else {
            String url = await CloudinaryService().uploadImage(
              photoPath,
              folder: 'pets/$uid',
            );
            uploadedUrls.add(url);
          }
        }

        final pet = Pet(
          id: widget.pet?.id ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          breed: _breedController.text.trim(),
          emoji: _selectedEmoji,
          bgColor: _selectedBgColor,
          age: _ageController.text.trim(),
          personality: _personalityController.text.trim(),
          photos: uploadedUrls,
        );

        if (widget.pet == null) {
          context.read<PetBloc>().add(AddPet(uid: uid, pet: pet));
        } else {
          context.read<PetBloc>().add(UpdatePet(uid: uid, pet: pet));
        }

        Navigator.pop(context); // Cerrar loading
        Navigator.pop(context); // Volver atrás
      } catch (e) {
        Navigator.pop(context); // Cerrar loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir imágenes: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.pet != null;

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
          isEditing ? 'Editar mascota' : 'Nueva mascota',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _savePet,
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Emoji selector
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Color(int.parse(_selectedBgColor)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(_selectedEmoji,
                      style: const TextStyle(fontSize: 50)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Tipo de animal',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: _animalEmojis.map((emoji) {
                final isSelected = emoji == _selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = emoji),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppTheme.primaryPink.withOpacity(0.2)
                          : AppTheme.inputBackground(context),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryPink
                            : AppTheme.borderColor(context),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            Text(
              'Color de fondo',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: _bgColors.map((colorStr) {
                final isSelected = colorStr == _selectedBgColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedBgColor = colorStr),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(int.parse(colorStr)),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryPink
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            _buildTextField(
              label: 'Nombre',
              controller: _nameController,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Introduce el nombre' : null,
            ),

            const SizedBox(height: 20),

            _buildTextField(
              label: 'Raza',
              controller: _breedController,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Introduce la raza' : null,
            ),

            const SizedBox(height: 20),

            _buildTextField(
              label: 'Edad',
              controller: _ageController,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Introduce la edad' : null,
            ),

            const SizedBox(height: 20),

            _buildTextField(
              label: 'Personalidad',
              controller: _personalityController,
              maxLines: 3,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Describe su personalidad'
                  : null,
            ),

            const SizedBox(height: 32),

            Text(
              'Fotos',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary(context),
              ),
            ),

            const SizedBox(height: 12),

            ImagePickerWidget(
              imagePaths: _photos,
              bgColor: Color(int.parse(_selectedBgColor)),
              onImageAdded: (path) {
                setState(() {
                  _photos.add(path);
                });
              },
              onImageRemoved: (index) {
                setState(() {
                  _photos.removeAt(index);
                });
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
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
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.inputBackground(context),
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
              borderSide:
                  BorderSide(color: AppTheme.primaryPink, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}