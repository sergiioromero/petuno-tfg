import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  // Singleton
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  static const String _cloudName = 'dtybzczug';
  static const String _uploadPreset = 'petuno_uploads';

  late final CloudinaryPublic _cloudinary;

  void init() {
    _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
  }

  /// Sube una imagen y devuelve la URL
  Future<String> uploadImage(String filePath, {String folder = 'pets'}) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          filePath,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Error al subir imagen a Cloudinary: $e');
    }
  }

  Future<List<String>> uploadImages(
    List<String> filePaths, {
    String folder = 'pets',
  }) async {
    List<String> urls = [];
    for (String path in filePaths) {
      String url = await uploadImage(path, folder: folder);
      urls.add(url);
    }
    return urls;
  }

  /// Elimina una imagen
  Future<void> deleteImage(String publicId) async {
    throw UnimplementedError('Para eliminar usa el dashboard de Cloudinary');
  }
}