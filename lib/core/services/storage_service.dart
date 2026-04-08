
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage({
    required String pathOrName, 
    required Uint8List data,
    required String folder,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$pathOrName';
      final ref = _storage.ref().child('$folder/$fileName');
      
      debugPrint('DEBUG: Starting putData to ${ref.fullPath} (Size: ${data.length} bytes)');
      
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploaded_by': 'user_app'},
      );

      final uploadTask = ref.putData(data, metadata);
      
      // Monitor progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        debugPrint('DEBUG: Upload progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
      });

      await uploadTask;
      debugPrint('DEBUG: putData completed successfully');
      
      debugPrint('DEBUG: Fetching download URL...');
      final url = await ref.getDownloadURL();
      debugPrint('DEBUG: Download URL obtained: $url');
      
      return url;
    } catch (e) {
      debugPrint('DEBUG: Storage Error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Ignore if file doesn't exist
      print('Error deleting image: $e');
    }
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});
