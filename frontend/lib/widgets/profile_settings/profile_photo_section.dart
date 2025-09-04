import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePhotoSection extends StatefulWidget {
  final String? profileImageUrl;
  final Function(File?) onPhotoChanged;

  const ProfilePhotoSection({
    super.key,
    this.profileImageUrl,
    required this.onPhotoChanged,
  });

  @override
  State<ProfilePhotoSection> createState() => _ProfilePhotoSectionState();
}

class _ProfilePhotoSectionState extends State<ProfilePhotoSection> {
  File? _profilePhoto;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoadingPhoto = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile Photo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: () {
              _showPhotoPickerDialog();
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: CupertinoColors.systemGrey4,
                  width: 2,
                ),
              ),
              child: _isLoadingPhoto
                  ? const CupertinoActivityIndicator()
                  : _profilePhoto != null
                      ? ClipOval(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: CupertinoColors.activeBlue,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Image.file(
                              _profilePhoto!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : widget.profileImageUrl != null
                          ? ClipOval(
                              child: Image.network(
                                widget.profileImageUrl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildDefaultAvatar();
                                },
                              ),
                            )
                          : _buildDefaultAvatar(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _profilePhoto != null ? 'Tap to change photo' : 'Tap to add photo',
            style: TextStyle(
              fontSize: 14,
              color: _profilePhoto != null ? CupertinoColors.activeBlue : CupertinoColors.systemGrey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: CupertinoColors.activeBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: const Icon(
        CupertinoIcons.person_fill,
        size: 50,
        color: CupertinoColors.activeBlue,
      ),
    );
  }

  void _showPhotoPickerDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Choose Photo'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(context).pop();
              await _takePhoto();
            },
            child: const Text('Take Photo'),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(context).pop();
              await _pickImageFromGallery();
            },
            child: const Text('Choose from Gallery'),
          ),
          if (_profilePhoto != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
                _removePhoto();
              },
              isDestructiveAction: true,
              child: const Text('Remove Photo'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    setState(() {
      _isLoadingPhoto = true;
    });
    
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );
      
      if (photo != null) {
        final File photoFile = File(photo.path);
        if (await _validateImageFile(photoFile)) {
          setState(() {
            _profilePhoto = photoFile;
          });
          widget.onPhotoChanged(_profilePhoto);
        }
      }
    } catch (e) {
      String errorMessage = 'Failed to take photo';
      if (e.toString().contains('permission')) {
        errorMessage = 'Camera permission denied. Please enable camera access in settings.';
      } else if (e.toString().contains('camera')) {
        errorMessage = 'Camera not available. Please check your device camera.';
      }
      _showErrorDialog(errorMessage);
    } finally {
      setState(() {
        _isLoadingPhoto = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    setState(() {
      _isLoadingPhoto = true;
    });
    
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );
      
      if (image != null) {
        final File imageFile = File(image.path);
        if (await _validateImageFile(imageFile)) {
          setState(() {
            _profilePhoto = imageFile;
          });
          widget.onPhotoChanged(_profilePhoto);
        }
      }
    } catch (e) {
      String errorMessage = 'Failed to pick image';
      if (e.toString().contains('permission')) {
        errorMessage = 'Gallery permission denied. Please enable photo library access in settings.';
      } else if (e.toString().contains('gallery')) {
        errorMessage = 'Gallery not available. Please check your device photo library.';
      }
      _showErrorDialog(errorMessage);
    } finally {
      setState(() {
        _isLoadingPhoto = false;
      });
    }
  }

  void _removePhoto() {
    setState(() {
      _profilePhoto = null;
    });
    widget.onPhotoChanged(null);
  }

  Future<bool> _validateImageFile(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        _showErrorDialog('Selected image file is not accessible.');
        return false;
      }

      final int fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        _showErrorDialog('Image file is too large. Please select an image smaller than 5MB.');
        return false;
      }

      return true;
    } catch (e) {
      _showErrorDialog('Failed to validate image file: ${e.toString()}');
      return false;
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
