import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/post_remote_datasource.dart';
import '../../data/models/post_model.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRemoteDataSource dataSource;

  PostBloc({required this.dataSource}) : super(PostInitial()) {
    on<LoadPosts>(_onLoadPosts);
    on<ToggleLikePost>(_onToggleLike);
  }

  Future<void> _onLoadPosts(LoadPosts event, Emitter<PostState> emit) async {
    emit(PostLoading());
    try {
      final posts = await dataSource.getPosts();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostError('Error al cargar publicaciones'));
    }
  }

  Future<void> _onToggleLike(ToggleLikePost event, Emitter<PostState> emit) async {
    if (state is! PostsLoaded) return;
    final current = (state as PostsLoaded).posts;

    // Actualiza localmente primero (optimista)
    final updated = current.map((p) {
      if (p.id != event.postId) return p;
      final liked = p.likedBy.contains(event.uid);
      final newLikedBy = List<String>.from(p.likedBy);
      liked ? newLikedBy.remove(event.uid) : newLikedBy.add(event.uid);
      return PostModel(
        id: p.id, uid: p.uid, userName: p.userName,
        avatarEmoji: p.avatarEmoji,
        userPhotoURL: p.userPhotoURL,
        petName: p.petName,
        petBreed: p.petBreed, petEmoji: p.petEmoji,
        bgColor: p.bgColor, petPhotoURL: p.petPhotoURL,
        photoURLs: p.photoURLs,
        description: p.description, tags: p.tags,
        likes: newLikedBy.length, likedBy: newLikedBy,
        comments: p.comments, createdAt: p.createdAt,
      );
    }).toList();

    emit(PostsLoaded(updated));
    await dataSource.toggleLike(event.postId, event.uid);
  }
}