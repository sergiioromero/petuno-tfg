import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/pet/pet_bloc.dart';
import '../bloc/pet/pet_state.dart';
import 'pet_detail_page.dart';
import 'edit_pet_page.dart';

class MyPetsPage extends StatelessWidget {
  final int? initialIndex;

  const MyPetsPage({super.key, this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.cardColor(context),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary(context)),
        ),
        title: Text(
          'Mis mascotas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary(context),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<PetBloc>(),
                    child: const EditPetPage(),
                  ),
                ),
              );
            },
            icon: Icon(Icons.add_circle_outline,
                color: AppTheme.primaryPink, size: 26),
          ),
        ],
      ),
      body: BlocBuilder<PetBloc, PetState>(
        builder: (context, state) {
          if (state is PetLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryPink),
            );
          }

          if (state is PetError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 60, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                ],
              ),
            );
          }

          if (state is! PetLoaded) {
            return const Center(child: Text('Sin mascotas'));
          }

          final pets = state.pets;

          if (pets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets_outlined,
                    size: 80,
                    color: AppTheme.textSecondary(context).withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aún no tienes mascotas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Añade tu primera mascota',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<PetBloc>(),
                        child: PetDetailPage(pet: pet),
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  // clipBehavior hace que el hijo respete el borderRadius
                  // sin necesidad de ClipRRect extra — elimina los bordes blancos
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderColor(context)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar circular
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(int.parse(pet.bgColor)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: pet.photos.isNotEmpty
                                ? Image.network(
                                    pet.photos.first,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Text(pet.emoji,
                                          style: const TextStyle(fontSize: 36)),
                                    ),
                                  )
                                : Center(
                                    child: Text(pet.emoji,
                                        style: const TextStyle(fontSize: 36)),
                                  ),
                          ),
                        ),
                      ),

                      // Info
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pet.name,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pet.breed,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary(context),
                                ),
                              ),
                              if (pet.age.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryPink
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${pet.age} años',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryPink,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Flecha
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(Icons.chevron_right,
                            color: AppTheme.textSecondary(context)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}