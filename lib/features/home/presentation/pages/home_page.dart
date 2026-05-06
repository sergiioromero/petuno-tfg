import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petuno_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:petuno_app/features/home/presentation/pages/create_post_page.dart';
import 'package:petuno_app/features/profile/presentation/bloc/pet/pet_bloc.dart';
import 'package:petuno_app/features/profile/presentation/bloc/profile/profile_bloc.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/stories_row.dart';
import '../widgets/user_suggestions_row.dart';
import '../widgets/post_card.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../bloc/post_bloc.dart';
import '../bloc/post_state.dart';
import '../bloc/post_event.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: const HomeAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: context.read<PostBloc>()),
                  BlocProvider.value(value: context.read<AuthBloc>()),
                  BlocProvider.value(value: context.read<ProfileBloc>()),
                  BlocProvider.value(value: context.read<PetBloc>()),
                ],
                child: const CreatePostPage(),
              ),
            ),
          );
        },
        backgroundColor: AppTheme.primaryPink,
        elevation: 3,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryPink,
        onRefresh: () async {
          context.read<PostBloc>().add(LoadPosts());
        },
        child: ListView(
          children: [
            const SizedBox(height: 12),
            const StoriesRow(),
            const SizedBox(height: 20),
            const UserSuggestionsRow(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Publicaciones recientes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary(context),
                ),
              ),
            ),
            const SizedBox(height: 8),
            BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                if (state is PostLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator(
                      color: AppTheme.primaryPink,
                    )),
                  );
                } else if (state is PostsLoaded) {
                  if (state.posts.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'Aún no hay publicaciones 🐾',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary(context),
                          ),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: state.posts
                        .map((post) => PostCard(post: post))
                        .toList(),
                  );
                } else if (state is PostError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text(state.message)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}