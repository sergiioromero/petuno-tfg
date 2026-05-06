import '../../data/models/post_model.dart';

abstract class PostState {}
class PostInitial extends PostState {}
class PostLoading extends PostState {}
class PostsLoaded extends PostState {
  final List<PostModel> posts;
  PostsLoaded(this.posts);
}
class PostError extends PostState {
  final String message;
  PostError(this.message);
}