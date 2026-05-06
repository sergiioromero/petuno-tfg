import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/services/cloudinary_service.dart';
import '../../../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../../../features/profile/presentation/bloc/profile/profile_bloc.dart';
import '../../../../../../features/profile/presentation/bloc/profile/profile_state.dart';
import '../../../../../../features/profile/presentation/bloc/pet/pet_bloc.dart';
import '../../../../../../features/profile/presentation/bloc/pet/pet_state.dart';
import '../../../../../../features/profile/domain/entities/pet.dart';
import '../bloc/post_bloc.dart';
import '../bloc/post_event.dart';
import '../../data/datasources/post_remote_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _descController = TextEditingController();
  final _tagsController = TextEditingController();
  final _picker = ImagePicker();

  List<File> _selectedImages = [];
  Pet? _selectedPet;
  bool _isLoading = false;

  @override
  void dispose() {
    _descController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() {
        _selectedImages = picked.map((x) => File(x.path)).toList();
      });
    }
  }

  Future<void> _publish() async {
    if (_descController.text.trim().isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Añade una foto o descripción')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) return;
      final uid = authState.user.uid;

      final profileState = context.read<ProfileBloc>().state;
      final userName = profileState is ProfileLoaded
          ? profileState.user.name
          : '';
      final avatarEmoji = profileState is ProfileLoaded
          ? profileState.user.avatarEmoji
          : '👤';
      final photoURL = profileState is ProfileLoaded
          ? profileState.user.photoURL
          : null;

      // Subir fotos a Cloudinary
      List<String> photoURLs = [];
      if (_selectedImages.isNotEmpty) {
        photoURLs = await CloudinaryService().uploadImages(
          _selectedImages.map((f) => f.path).toList(),
          folder: 'posts',
        );
      }

      // Tags
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim().replaceAll('#', ''))
          .where((t) => t.isNotEmpty)
          .toList();

      // Datos de mascota (opcional)
      final petName = _selectedPet?.name ?? '';
      final petBreed = _selectedPet?.breed ?? '';
      final petEmoji = _selectedPet?.emoji ?? '🐾';
      final bgColor = _selectedPet?.bgColor ?? '0xFFFFF3E0';
      final petPhotoURL = _selectedPet?.photos.isNotEmpty == true
          ? _selectedPet!.photos.first
          : (photoURLs.isNotEmpty ? photoURLs.first : null);

      await FirebaseFirestore.instance.collection('posts').add({
        'uid': uid,
        'userName': userName,
        'avatarEmoji': avatarEmoji,
        'userPhotoURL': photoURL,
        'petName': petName,
        'petBreed': petBreed,
        'petEmoji': petEmoji,
        'bgColor': bgColor,
        'petPhotoURL': petPhotoURL,
        'photoURLs': photoURLs,
        'description': _descController.text.trim(),
        'tags': tags,
        'likes': 0,
        'likedBy': [],
        'comments': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        context.read<PostBloc>().add(LoadPosts());
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al publicar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final petState = context.watch<PetBloc>().state;
    final pets = petState is PetLoaded ? petState.pets : <Pet>[];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Nueva publicación',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary(context),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close_rounded,
              color: AppTheme.textPrimary(context)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isLoading ? null : _publish,
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.primaryPink,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Publicar',
                      style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Selector de fotos
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: double.infinity,
                height: _selectedImages.isEmpty ? 180 : null,
                decoration: BoxDecoration(
                  color: AppTheme.inputBackground(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedImages.isEmpty
                        ? AppTheme.borderColor(context)
                        : AppTheme.primaryPink,
                    width: 1.5,
                  ),
                ),
                child: _selectedImages.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 48,
                              color: AppTheme.textSecondary(context)),
                          const SizedBox(height: 10),
                          Text(
                            'Toca para añadir fotos',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppTheme.textSecondary(context),
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 220,
                              child: PageView.builder(
                                itemCount: _selectedImages.length,
                                itemBuilder: (_, i) => Image.file(
                                  _selectedImages[i],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            if (_selectedImages.length > 1)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  '${_selectedImages.length} fotos · desliza para ver',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary(context),
                                  ),
                                ),
                              ),
                            TextButton.icon(
                              onPressed: _pickImages,
                              icon: Icon(Icons.edit,
                                  size: 16, color: AppTheme.primaryPink),
                              label: Text('Cambiar fotos',
                                  style: TextStyle(
                                      color: AppTheme.primaryPink,
                                      fontSize: 13)),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // Descripción
            TextField(
              controller: _descController,
              maxLines: 4,
              maxLength: 300,
              style: TextStyle(
                  fontSize: 15, color: AppTheme.textPrimary(context)),
              decoration: InputDecoration(
                hintText: 'Cuéntanos algo sobre tu mascota...',
                hintStyle:
                    TextStyle(color: AppTheme.textSecondary(context)),
                filled: true,
                fillColor: AppTheme.inputBackground(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 16),

            // Tags
            TextField(
              controller: _tagsController,
              style: TextStyle(
                  fontSize: 15, color: AppTheme.textPrimary(context)),
              decoration: InputDecoration(
                hintText: 'Tags: perros, paseo, golden...',
                hintStyle:
                    TextStyle(color: AppTheme.textSecondary(context)),
                prefixIcon: Icon(Icons.tag,
                    color: AppTheme.textSecondary(context)),
                filled: true,
                fillColor: AppTheme.inputBackground(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 20),

            // Selector de mascota (opcional)
            if (pets.isNotEmpty) ...[
              Text(
                'Mascota (opcional)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary(context),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: pets.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Opción "Sin mascota"
                      final selected = _selectedPet == null;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedPet = null),
                        child: Container(
                          width: 70,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.primaryPink.withOpacity(0.1)
                                : AppTheme.inputBackground(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.primaryPink
                                  : AppTheme.borderColor(context),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pets_outlined,
                                  color: selected
                                      ? AppTheme.primaryPink
                                      : AppTheme.textSecondary(context),
                                  size: 22),
                              const SizedBox(height: 4),
                              Text(
                                'Ninguna',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: selected
                                      ? AppTheme.primaryPink
                                      : AppTheme.textSecondary(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final pet = pets[index - 1];
                    final selected = _selectedPet?.id == pet.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedPet = pet),
                      child: Container(
                        width: 70,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.primaryPink.withOpacity(0.1)
                              : AppTheme.inputBackground(context),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? AppTheme.primaryPink
                                : AppTheme.borderColor(context),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            pet.photos.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      pet.photos.first,
                                      width: 36,
                                      height: 36,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Text(pet.emoji,
                                    style: const TextStyle(fontSize: 28)),
                            const SizedBox(height: 4),
                            Text(
                              pet.name,
                              style: TextStyle(
                                fontSize: 10,
                                color: selected
                                    ? AppTheme.primaryPink
                                    : AppTheme.textSecondary(context),
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}