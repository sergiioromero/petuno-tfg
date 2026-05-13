abstract class PostEvent {}

class LoadPosts extends PostEvent {}

class ToggleLikePost extends PostEvent {
  final String postId;
  final String uid;
  ToggleLikePost(this.postId, this.uid);
}

class DeletePost extends PostEvent {
  final String postId;
  DeletePost(this.postId);
}

class AddComment extends PostEvent {
  final String postId;
  final String uid;
  final String userName;
  final String? userPhotoURL;
  final String text;
  AddComment({
    required this.postId,
    required this.uid,
    required this.userName,
    this.userPhotoURL,
    required this.text,
  });
}

class DeleteComment extends PostEvent {
  final String postId;
  final String commentId;
  DeleteComment(this.postId, this.commentId);
}
