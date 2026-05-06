import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petuno_app/features/profile/presentation/bloc/profile/profile_event.dart';
import 'package:petuno_app/features/profile/presentation/pages/settings_page.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_state.dart';
import '../bloc/pet/pet_bloc.dart';
import '../bloc/pet/pet_event.dart';
import '../bloc/pet/pet_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../widgets/profile_section.dart';
import '../widgets/pet_card.dart';
import 'my_pets_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _loadIfNeeded();
  }

  void _loadIfNeeded() {
    final profileState = context.read<ProfileBloc>().state;
    // Si no hay datos cargados, los pedimos nosotros mismos
    if (profileState is! ProfileLoaded) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<ProfileBloc>().add(LoadProfile(authState.user.uid));
        context.read<PetBloc>().add(LoadPets(authState.user.uid));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            if (profileState is ProfileLoading ||
                profileState is ProfileInitial) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryPink,
                ),
              );
            }

            if (profileState is ProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 60, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text('Error: ${profileState.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadIfNeeded,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (profileState is! ProfileLoaded) {
              return Center(
                child: CircularProgressIndicator(color: AppTheme.primaryPink),
              );
            }

            final user = profileState.user;

            return BlocBuilder<PetBloc, PetState>(
              builder: (context, petState) {
                final pets = petState is PetLoaded ? petState.pets : [];

                return ListView(
                  children: [
                    const SizedBox(height: 16),

                    // Botones de acción superior
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SettingsPage(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.settings_outlined,
                              color: AppTheme.textPrimary(context),
                              size: 26,
                            ),
                          ),
                          IconButton(
                            onPressed: () => themeProvider.toggleTheme(),
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return RotationTransition(
                                  turns: animation,
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Icon(
                                themeProvider.isDarkMode
                                    ? Icons.light_mode_rounded
                                    : Icons.dark_mode_rounded,
                                key: ValueKey(themeProvider.isDarkMode),
                                color: themeProvider.isDarkMode
                                    ? Colors.amber
                                    : AppTheme.textPrimary(context),
                                size: 26,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Header
                    ProfileHeader(user: user),

                    const SizedBox(height: 24),

                    // Estadísticas
                    ProfileStats(user: user),

                    const SizedBox(height: 20),

                    // Botón editar perfil
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<ProfileBloc>(),
                                  child: EditProfilePage(user: user),
                                ),
                              ),
                            ).then((_) {
                              if (context.mounted) {
                                context
                                    .read<ProfileBloc>()
                                    .add(LoadProfile(user.id));
                              }
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: AppTheme.borderColor(context),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Editar perfil',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary(context),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Bio
                    ProfileSection(
                      title: 'Bio',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          user.bio,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textPrimary(context),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Intereses
                    ProfileSection(
                      title: 'Intereses',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: user.interests
                              .map(
                                (interest) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.primaryPink.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppTheme.primaryPink
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    interest,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryPink,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Mis mascotas
                    ProfileSection(
                      title: 'Mis mascotas',
                      child: Column(
                        children: [
                          if (pets.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.pets_outlined,
                                    size: 60,
                                    color: AppTheme.textSecondary(context)
                                        .withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Aún no tienes mascotas',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppTheme.textSecondary(context),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            SizedBox(
                              height: 160,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                itemCount: pets.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final pet = pets[index];
                                  return PetCard(
                                    pet: pet,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider.value(
                                            value: context.read<PetBloc>(),
                                            child: MyPetsPage(
                                                initialIndex: index),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 12),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: context.read<PetBloc>(),
                                        child: const MyPetsPage(),
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.pets,
                                    color: AppTheme.primaryPink, size: 20),
                                label: Text(
                                  pets.isEmpty
                                      ? 'Añadir mi primera mascota'
                                      : 'Ver todas mis mascotas',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryPink,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: AppTheme.primaryPink,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
