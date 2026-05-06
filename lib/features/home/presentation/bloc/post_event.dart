abstract class PostEvent {}
class LoadPosts extends PostEvent {}
class ToggleLikePost extends PostEvent {
  final String postId;
  final String uid;
  ToggleLikePost(this.postId, this.uid);
}