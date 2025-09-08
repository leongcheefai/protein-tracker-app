import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../services/service_locator.dart';
import '../services/food_service.dart';
import '../models/api_response.dart';
import '../models/dto/food_dto.dart';

class CameraService {
  final FoodService _foodService = ServiceLocator().foodService;
  final ImagePicker _imagePicker = ImagePicker();

  // Camera capture methods
  Future<File?> capturePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw CameraException('camera_capture_failed', 'Failed to capture photo: $e');
    }
  }

  Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw CameraException('gallery_pick_failed', 'Failed to pick image from gallery: $e');
    }
  }

  // Image processing methods (simplified without image package)
  Future<File> optimizeForUpload(File image) async {
    // For now, return the original image
    // In a production app, you might want to add the image package
    // or use platform-specific image compression
    return image;
  }

  // Backend integration methods
  Future<ApiResponse<FoodDetectionResultDto>> uploadAndAnalyze(
    File image, {
    Function(int sent, int total)? onProgress,
    bool optimizeBeforeUpload = true,
  }) async {
    try {
      File imageToUpload = image;
      
      // Optimize image for upload if requested
      if (optimizeBeforeUpload) {
        imageToUpload = await optimizeForUpload(image);
      }

      // Upload and analyze with the food service
      final response = await _foodService.detectFoodFromImage(
        imageToUpload,
        onProgress: onProgress,
      );

      // Clean up compressed file if it was created
      if (optimizeBeforeUpload && imageToUpload.path != image.path) {
        try {
          await imageToUpload.delete();
        } catch (e) {
          // Ignore cleanup errors
        }
      }

      return response;
    } catch (e) {
      throw Exception('Failed to upload and analyze image: $e');
    }
  }

  Future<ApiResponse<FoodDetectionResultDto>> analyzeImageFromPath(
    String imagePath, {
    Function(int sent, int total)? onProgress,
  }) async {
    final imageFile = File(imagePath);
    
    if (!await imageFile.exists()) {
      return ApiResponse.error(
        ApiError.validation('Image file does not exist'),
      );
    }

    return await uploadAndAnalyze(
      imageFile,
      onProgress: onProgress,
    );
  }

  // Utility methods
  Future<bool> validateImage(File image) async {
    try {
      if (!await image.exists()) {
        return false;
      }

      // Basic validation - check if file has bytes
      final stat = await image.stat();
      return stat.size > 0;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getImageMetadata(File image) async {
    try {
      final stat = await image.stat();

      return {
        'size': stat.size,
        'format': image.path.split('.').last.toLowerCase(),
        'created': stat.modified,
      };
    } catch (e) {
      throw Exception('Failed to get image metadata: $e');
    }
  }

  // Camera permissions and availability
  Future<bool> isCameraAvailable() async {
    try {
      final cameras = await availableCameras();
      return cameras.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<List<CameraDescription>> getAvailableCameras() async {
    try {
      return await availableCameras();
    } catch (e) {
      return [];
    }
  }

  // Batch processing methods
  Future<List<ApiResponse<FoodDetectionResultDto>>> analyzeMultipleImages(
    List<File> images, {
    Function(int current, int total)? onProgress,
  }) async {
    final results = <ApiResponse<FoodDetectionResultDto>>[];
    
    for (int i = 0; i < images.length; i++) {
      onProgress?.call(i + 1, images.length);
      
      try {
        final result = await uploadAndAnalyze(images[i]);
        results.add(result);
      } catch (e) {
        results.add(ApiResponse.error(
          ApiError.server('Failed to analyze image ${i + 1}: $e'),
        ));
      }
    }
    
    return results;
  }

  // Clean up temporary files
  Future<void> cleanupTemporaryFiles() async {
    // This would clean up any temporary compressed files
    // Implementation depends on how you want to manage temp files
    try {
      final tempDir = Directory.systemTemp;
      final tempFiles = await tempDir.list().where((entity) {
        return entity is File && 
               entity.path.contains('_compressed.jpg') ||
               entity.path.contains('protein_tracker_temp');
      }).toList();
      
      for (final file in tempFiles) {
        try {
          await file.delete();
        } catch (e) {
          // Ignore individual file deletion errors
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }
}

// Custom exceptions
class CameraException implements Exception {
  final String code;
  final String message;
  
  CameraException(this.code, this.message);
  
  @override
  String toString() => 'CameraException($code): $message';
}