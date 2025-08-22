import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

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
  bool _hasPermission = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
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

  Future<void> _checkPermissions() async {
    print('Checking camera permissions...');
    
    // First check current status
    final currentStatus = await Permission.camera.status;
    print('Current camera permission status: $currentStatus');
    
    if (currentStatus.isGranted) {
      print('Camera permission already granted');
      setState(() {
        _hasPermission = true;
        _isLoading = false;
      });
      await _initializeCamera();
      return;
    }
    
    if (currentStatus.isDenied) {
      print('Camera permission denied, requesting...');
      final status = await Permission.camera.request();
      print('Permission request result: $status');
      
      setState(() {
        _hasPermission = status.isGranted;
        _isLoading = false;
      });
      
      if (_hasPermission) {
        await _initializeCamera();
      }
    } else if (currentStatus.isPermanentlyDenied) {
      print('Camera permission permanently denied');
      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });
    } else {
      print('Unknown permission status: $currentStatus');
      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  Future<void> _retryPermission() async {
    setState(() {
      _isLoading = true;
    });
    
    final status = await Permission.camera.request();
    setState(() {
      _hasPermission = status.isGranted;
      _isLoading = false;
    });
    
    if (_hasPermission) {
      await _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      _controller = CameraController(
        _cameras[_selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      
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
        _showErrorDialog('Camera initialization failed: $e');
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Preview
            if (_isInitialized && _controller != null)
              CameraPreview(_controller!)
            else if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            else
              _buildPermissionDeniedView(),

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
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.5),
                        shape: const CircleBorder(),
                      ),
                    ),
                    const Text(
                      'Take Photo',
                      style: TextStyle(
                        color: Colors.white,
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
            IconButton(
              onPressed: _toggleFlash,
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
                size: 28,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                shape: const CircleBorder(),
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
                  border: Border.all(color: Colors.white, width: 4),
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: const Icon(
                  Icons.camera,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),

            // Camera Flip Button
            if (_cameras.length > 1)
              IconButton(
                onPressed: _switchCamera,
                icon: const Icon(
                  Icons.flip_camera_ios,
                  color: Colors.white,
                  size: 28,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                  shape: const CircleBorder(),
                ),
              )
            else
              const SizedBox(width: 48), // Balance the layout
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionDeniedView() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'Camera Permission Required',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Protein Pace needs camera access to analyze your meals and track protein intake.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'To enable camera access:\n1. Tap "Open Settings"\n2. Find "Protein Pace" in the list\n3. Tap "Camera" and select "Allow"',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _openSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Open Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _retryPermission,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () async {
                print('Testing camera permission request...');
                final status = await Permission.camera.request();
                print('Test permission result: $status');
                if (status.isGranted) {
                  print('Permission granted!');
                  setState(() {
                    _hasPermission = true;
                  });
                  await _initializeCamera();
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Test Permission',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Maybe Later',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
