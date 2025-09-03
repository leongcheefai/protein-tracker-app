import 'dart:io';
import 'package:flutter/cupertino.dart';

class PhotoCaptureScreen extends StatefulWidget {
  final String imagePath;

  const PhotoCaptureScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<PhotoCaptureScreen> createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        child: Stack(
          children: [
            // Full Screen Image
            Positioned.fill(
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: CupertinoColors.systemGrey,
                    child: const Center(
                      child: Text(
                        'Failed to load image',
                        style: TextStyle(color: CupertinoColors.white),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Top Controls
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close Button
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: CupertinoColors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.xmark,
                        color: CupertinoColors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  
                  // Spacer to balance layout
                  const SizedBox(width: 48), // Balance the layout
                ],
              ),
            ),

            // Focus Indicator (Center) - Static version
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoColors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            // Bottom Controls
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Retake Button
                  Expanded(
                    child: GestureDetector(
                      onTap: _isProcessing ? null : _retakePhoto,
                      child: Container(
                        height: 60,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemRed.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: CupertinoColors.white, width: 2),
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.refresh,
                                color: CupertinoColors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Retake',
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Use Photo Button
                  Expanded(
                    child: GestureDetector(
                      onTap: _isProcessing ? null : _usePhoto,
                      child: Container(
                        height: 60,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGreen.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: CupertinoColors.white, width: 2),
                        ),
                        child: Center(
                          child: _isProcessing
                              ? const CupertinoActivityIndicator(
                                  color: CupertinoColors.white,
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.check_mark,
                                      color: CupertinoColors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Use Photo',
                                      style: TextStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _retakePhoto() async {
    if (_isProcessing) return;
    
    try {
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _usePhoto() async {
    if (_isProcessing) return;
    
    try {
      setState(() {
        _isProcessing = true;
      });
      
      // Simulate processing time
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        
        Navigator.pushReplacementNamed(
          context,
          '/processing',
          arguments: widget.imagePath,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Navigation Error'),
            content: Text('Failed to proceed: $e'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}