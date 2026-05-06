import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petuno_app/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:petuno_app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:petuno_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:petuno_app/features/chat/presentation/bloc/chat_event.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Core
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/widgets/main_navigation.dart';
import 'firebase_options.dart';

// Profile - Data
import 'features/profile/data/datasources/user_remote_datasource.dart';
import 'features/profile/data/datasources/pet_remote_datasource.dart';
import 'features/profile/data/repositories/user_repository_impl.dart';
import 'features/profile/data/repositories/pet_repository_impl.dart';

// Profile - Dominio
import 'features/profile/domain/usecases/get_user.dart';
import 'features/profile/domain/usecases/update_user.dart';
import 'features/profile/domain/usecases/update_photo_url.dart';
import 'features/profile/domain/usecases/get_pets.dart';
import 'features/profile/domain/usecases/add_pet.dart' as uc_add;
import 'features/profile/domain/usecases/update_pet.dart' as uc_update;
import 'features/profile/domain/usecases/delete_pet.dart' as uc_delete;

// Profile - Presentacion
import 'features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'features/profile/presentation/bloc/profile/profile_event.dart';
import 'features/profile/presentation/bloc/profile/profile_state.dart';
import 'features/profile/presentation/bloc/pet/pet_bloc.dart';
import 'features/profile/presentation/bloc/pet/pet_event.dart';

// Auth - Data
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';

// Auth - Dominio
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/login.dart';
import 'features/auth/domain/usecases/register.dart';
import 'features/auth/domain/usecases/logout.dart';

// Auth - Presentacion
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';

// Paginas
import 'features/welcome/presentation/pages/welcome_page.dart';

import 'features/home/data/datasources/post_remote_datasource.dart';
import 'features/home/presentation/bloc/post_bloc.dart';
import 'features/home/presentation/bloc/post_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PetunoApp());
}

class PetunoApp extends StatelessWidget {
  const PetunoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MultiBlocProvider(
        providers: [
          // Auth BLoC
          BlocProvider(
            create: (context) {
              final authRemoteDataSource = AuthRemoteDataSourceImpl(
                firebaseAuth: FirebaseAuth.instance,
                firestore: FirebaseFirestore.instance,
              );
              final authRepository = AuthRepositoryImpl(
                remoteDataSource: authRemoteDataSource,
              );
              return AuthBloc(
                getCurrentUser: GetCurrentUser(authRepository),
                login: Login(authRepository),
                register: Register(authRepository),
                logout: Logout(authRepository),
              )..add(AuthCheckRequested());
            },
          ),

          // Profile BLoC — Firestore + Cloudinary para foto
          BlocProvider(
            create: (context) {
              final userRemoteDataSource = UserRemoteDataSourceImpl(
                firestore: FirebaseFirestore.instance,
              );
              final userRepository = UserRepositoryImpl(
                remoteDataSource: userRemoteDataSource,
              );
              return ProfileBloc(
                getUser: GetUser(userRepository),
                updateUser: UpdateUser(userRepository),
                updatePhotoURL: UpdatePhotoURL(userRepository),
              );
            },
          ),

          // Pet BLoC — ahora usa Firestore (subcolección users/{uid}/pets)
          BlocProvider(
            create: (context) {
              final petRemoteDataSource = PetRemoteDataSourceImpl(
                firestore: FirebaseFirestore.instance,
              );
              final petRepository = PetRepositoryImpl(
                remoteDataSource: petRemoteDataSource,
              );
              return PetBloc(
                getPets: GetPets(petRepository),
                addPet: uc_add.AddPet(petRepository),
                updatePet: uc_update.UpdatePet(petRepository),
                deletePet: uc_delete.DeletePet(petRepository),
              );
            },
          ),

          BlocProvider(
            create: (context) {
              final dataSource = ChatRemoteDataSourceImpl(
                firestore: FirebaseFirestore.instance,
              );
              final repository = ChatRepositoryImpl(remoteDataSource: dataSource);
              return ChatBloc(chatRepository: repository);
            },
          ),

          BlocProvider(
            create: (context) {
              final dataSource = PostRemoteDataSourceImpl(
                firestore: FirebaseFirestore.instance,
              );
              return PostBloc(dataSource: dataSource)..add(LoadPosts());
            },
          ),
        ],
        child: const PetunoAppView(),
      ),
    );
  }
}

class PetunoAppView extends StatelessWidget {
  const PetunoAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Petuno',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthUnauthenticated) {
          context.read<ChatBloc>().add(StopAllStreams());
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const WelcomePage()),
            (route) => false,
          );
        } else if (authState is AuthAuthenticated) {
          // ← MUÉVELO AQUÍ: solo se dispara una vez cuando cambia el estado
          context.read<ProfileBloc>().add(LoadProfile(authState.user.uid));
          context.read<PetBloc>().add(LoadPets(authState.user.uid));
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthLoading || authState is AuthInitial) {
            return const SplashScreen();
          } else if (authState is AuthAuthenticated) {
            return const MainNavigation(); // ← ya sin los .add() aquí
          } else {
            return const WelcomePage();
          }
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryPink,
                    AppTheme.primaryPink.withOpacity(0.6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPink.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.pets, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Petuno',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111111),
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 32),
            CircularProgressIndicator(color: AppTheme.primaryPink),
          ],
        ),
      ),
    );
  }
}