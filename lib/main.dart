import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Core
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/widgets/main_navigation.dart';
import 'core/services/cloudinary_service.dart';
import 'firebase_options.dart';

// Profile
import 'features/profile/data/datasources/local_storage.dart';
import 'features/profile/data/datasources/user_local_datasource.dart';
import 'features/profile/data/datasources/pet_local_datasource.dart';
import 'features/profile/data/repositories/user_repository_impl.dart';
import 'features/profile/data/repositories/pet_repository_impl.dart';

// Profile - Dominio
import 'features/profile/domain/usecases/get_user.dart';
import 'features/profile/domain/usecases/update_user.dart';
import 'features/profile/domain/usecases/get_pets.dart';
import 'features/profile/domain/usecases/add_pet.dart';
import 'features/profile/domain/usecases/update_pet.dart';
import 'features/profile/domain/usecases/delete_pet.dart';

// Profile - Presentacion
import 'features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'features/profile/presentation/bloc/profile/profile_event.dart';
import 'features/profile/presentation/bloc/pet/pet_bloc.dart';
import 'features/profile/presentation/bloc/pet/pet_event.dart' hide AddPet, UpdatePet, DeletePet;

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializar Hive
  await LocalStorage.init();

  // Inicializar Cloudinary
  CloudinaryService().init();

  runApp(const PetunoApp());
}

class PetunoApp extends StatelessWidget {
  const PetunoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme Provider
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // Auth BLoC
          BlocProvider(
            create: (context) {
              // Data Sources
              final authRemoteDataSource = AuthRemoteDataSourceImpl(
                firebaseAuth: FirebaseAuth.instance,
                firestore: FirebaseFirestore.instance,
              );

              // Repositories
              final authRepository = AuthRepositoryImpl(
                remoteDataSource: authRemoteDataSource,
              );

              // Use Cases
              final getCurrentUser = GetCurrentUser(authRepository);
              final login = Login(authRepository);
              final register = Register(authRepository);
              final logout = Logout(authRepository);

              // BLoC
              return AuthBloc(
                getCurrentUser: getCurrentUser,
                login: login,
                register: register,
                logout: logout,
              )..add(AuthCheckRequested());
            },
          ),

          // Profile BLoC
          BlocProvider(
            create: (context) {
              // Data Sources
              final userLocalDataSource = UserLocalDataSourceImpl();

              // Repositories
              final userRepository = UserRepositoryImpl(
                localDataSource: userLocalDataSource,
              );

              // Use Cases
              final getUser = GetUser(userRepository);
              final updateUser = UpdateUser(userRepository);

              // BLoC
              return ProfileBloc(
                getUser: getUser,
                updateUser: updateUser,
              );
            },
          ),

          // Pet BLoC
          BlocProvider(
            create: (context) {
              // Data Sources
              final petLocalDataSource = PetLocalDataSourceImpl();

              // Repositories
              final petRepository = PetRepositoryImpl(
                localDataSource: petLocalDataSource,
              );

              // Use Cases
              final getPets = GetPets(petRepository);
              final addPet = AddPet(petRepository);
              final updatePet = UpdatePet(petRepository);
              final deletePet = DeletePet(petRepository);

              // BLoC
              return PetBloc(
                getPets: getPets,
                addPet: addPet,
                updatePet: updatePet,
                deletePet: deletePet,
              );
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          // Mostrando splash mientras verifica autenticación
          return const SplashScreen();
        } else if (state is AuthAuthenticated) {
          // Usuario autenticado - cargar datos y mostrar home
          context.read<ProfileBloc>().add(LoadProfile());
          context.read<PetBloc>().add(LoadPets());
          return const MainNavigation();
        } else {
          // Usuario no autenticado - mostrar welcome
          return const WelcomePage();
        }
      },
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
            // Logo
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
                child: Icon(
                  Icons.pets,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Nombre de la app
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

            // Loading
            CircularProgressIndicator(
              color: AppTheme.primaryPink,
            ),
          ],
        ),
      ),
    );
  }
}