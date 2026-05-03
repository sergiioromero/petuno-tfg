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
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.textPrimary(context),
          ),
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
              child: CircularProgressIndicator(
                color: AppTheme.primaryPink,
              ),
            );
          }

          if (state is PetError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
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
                  margin: const EdgeInsets.only(bottom: 16),
                  height: 120,
                  decoration: BoxDecoration(
                    color: Color(int.parse(pet.bgColor)),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Emoji
                        Positioned(
                          right: 20,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Text(
                              pet.emoji,
                              style: const TextStyle(fontSize: 70),
                            ),
                          ),
                        ),

                        // Degradado
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                stops: const [0.0, 0.6, 1.0],
                                colors: [
                                  Colors.black.withOpacity(0.5),
                                  Colors.transparent,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Info
                        Positioned(
                          left: 20,
                          top: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pet.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pet.breed,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ),
                                child: Text(
                                  pet.age,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
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
            },
          );
        },
      ),
    );
  }
}