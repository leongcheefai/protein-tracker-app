import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';

class CameraLaunchScreen extends StatefulWidget {
  const CameraLaunchScreen({super.key});

  @override
  State<CameraLaunchScreen> createState() => _CameraLaunchScreenState();
}

class _CameraLaunchScreenState extends State<CameraLaunchScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isInitialized = false;
  bool _isFlashOn = false;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  // Removed permission_handler logic - camera plugin handles permissions natively



  Future<void> _retryCameraInitialization() async {
    setState(() {
      _isLoading = true;
    });
    
    // Dispose existing controller
    await _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    
    // Retry initialization
    await _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Check if camera is available
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('No cameras found on this device. Please check your device camera.');
        return;
      }

      // Create camera controller
      _controller = CameraController(
        _cameras[_selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // Initialize camera with timeout
      await _controller!.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Camera initialization timeout. Please try again.');
        },
      );
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Handle permission-related errors with native iOS dialog
        if (e.toString().contains('permission') || e.toString().contains('denied')) {
          _showPermissionDialog();
        } else {
          String errorMessage = 'Camera initialization failed';
          if (e.toString().contains('CameraException')) {
            errorMessage = 'Camera is currently unavailable. Please close other camera apps and try again.';
          } else if (e.toString().contains('timeout')) {
            errorMessage = 'Camera initialization timeout. Please try again.';
          } else {
            errorMessage = 'Camera initialization failed: ${e.toString()}';
          }
          _showErrorDialog(errorMessage);
        }
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    
    final newIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _controller?.dispose();
    
    _controller = CameraController(
      _cameras[newIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );
    
    try {
      await _controller!.initialize();
      setState(() {
        _selectedCameraIndex = newIndex;
        _isInitialized = true;
      });
    } catch (e) {
      _showErrorDialog('Failed to switch camera: $e');
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller?.value.isInitialized ?? false) {
      try {
        await _controller!.setFlashMode(
          _isFlashOn ? FlashMode.off : FlashMode.torch,
        );
        setState(() {
          _isFlashOn = !_isFlashOn;
        });
      } catch (e) {
        _showErrorDialog('Failed to toggle flash: $e');
      }
    }
  }

  Future<void> _takePicture() async {
    if (!_isInitialized || _controller == null) return;

    try {
      final image = await _controller!.takePicture();
      if (mounted) {
        // Navigate to photo capture screen with the captured image
        Navigator.pushNamed(
          context,
          '/photo-capture',
          arguments: image.path,
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to take picture: $e');
    }
  }

  void _showPermissionDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Camera Access Required'),
        content: const Text('Fuelie needs access to your camera to take photos of your meals for AI analysis.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              _retryCameraInitialization();
            },
            child: const Text('Allow'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Camera Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              _retryCameraInitialization();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        child: Stack(
          children: [
            // Camera Preview
            if (_isInitialized && _controller != null)
              CameraPreview(_controller!)
            else if (_isLoading)
              const Center(
                child: CupertinoActivityIndicator(
                  color: CupertinoColors.white,
                ),
              )
            else
              _buildCameraUnavailableView(),

            // Camera Controls Overlay
            if (_isInitialized && _controller != null)
              _buildCameraControls(),

            // Top Bar with Back Button
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: CupertinoColors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.back,
                          color: CupertinoColors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const Text(
                      'Take Photo',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the layout
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Flash Toggle
            CupertinoButton(
              onPressed: _toggleFlash,
              padding: EdgeInsets.zero,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: CupertinoColors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isFlashOn ? CupertinoIcons.bolt_fill : CupertinoIcons.bolt,
                  color: CupertinoColors.white,
                  size: 24,
                ),
              ),
            ),

            // Capture Button
            GestureDetector(
              onTap: _takePicture,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: CupertinoColors.white, width: 4),
                  color: CupertinoColors.white.withValues(alpha: 0.2),
                ),
                child: const Icon(
                  CupertinoIcons.camera,
                  color: CupertinoColors.white,
                  size: 40,
                ),
              ),
            ),

            // Camera Flip Button
            if (_cameras.length > 1)
              CupertinoButton(
                onPressed: _switchCamera,
                padding: EdgeInsets.zero,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: CupertinoColors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.camera_rotate,
                    color: CupertinoColors.white,
                    size: 24,
                  ),
                ),
              )
            else
              const SizedBox(width: 48), // Balance the layout
          ],
        ),
      ),
    );
  }

  Widget _buildCameraUnavailableView() {
    return Container(
      color: CupertinoColors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.camera,
              color: CupertinoColors.white,
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'Camera Unavailable',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to access camera. Please try again.',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CupertinoButton.filled(
              onPressed: _retryCameraInitialization,
              child: const Text(
                'Try Again',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            CupertinoButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: CupertinoColors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
