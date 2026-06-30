import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../Services/image_helper.dart';
import '../constants.dart';
import '../widgets/app_ui.dart';
import 'input_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  Gender? selectedGender;
  File? profileImage;
  bool _showGenderWarning = false;
  bool _isProcessingPhoto = false;
  final ImagePicker _imagePicker = ImagePicker();
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _shakeGenderBlock() {
    HapticFeedback.lightImpact();
    _shakeController.forward(from: 0);
  }

  void _showGenderWarningMessage() {
    setState(() => _showGenderWarning = true);
    _shakeGenderBlock();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showGenderWarning = false);
    });
  }

  void _selectGender(Gender gender) {
    setState(() {
      selectedGender = gender;
      _showGenderWarning = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile;
      if (source == ImageSource.camera) {
        pickedFile = await _imagePicker.pickImage(
          source: source,
          imageQuality: 85,
          preferredCameraDevice: CameraDevice.front,
        );
      } else {
        pickedFile = await _imagePicker.pickImage(
          source: source,
          imageQuality: 85,
        );
      }
      if (pickedFile == null) return;

      setState(() => _isProcessingPhoto = true);
      try {
        final normalized = await ImageHelper.normalizeForDisplay(
          File(pickedFile.path),
          source,
        );

        if (!mounted) return;
        setState(() => profileImage = normalized);
      } finally {
        if (mounted) setState(() => _isProcessingPhoto = false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load image: $e')),
      );
    }
  }

  void _continue() {
    if (selectedGender == null) {
      _showGenderWarningMessage();
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => InputPage(
          preSelectedGender: selectedGender,
          profileImage: profileImage,
        ),
      ),
    );
  }

  void _showPhotoSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: AppColors.primary),
              title: const Text('Take photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (profileImage != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.danger),
                title: const Text('Remove photo', style: TextStyle(color: AppColors.danger)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => profileImage = null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppSpacing.page(context);

    return AppScaffold(
      actions: [
        IconButton(
          tooltip: 'Home',
          icon: const Icon(Icons.home_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        const SizedBox(width: 4),
      ],
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(padding, 8, padding, padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Image.asset('assets/icon/appIcon.png', width: 60, height: 60),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Your BMI', style: AppText.display(context), textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  Text(
                    'Understand your body metrics in few steps.',
                    style: AppText.body(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: child,
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SectionTitle('Gender'),
                        Row(
                          children: [
                            GenderChip(
                              label: 'Male',
                              icon: Icons.man_outlined,
                              selected: selectedGender == Gender.male,
                              onTap: () => _selectGender(Gender.male),
                            ),
                            const SizedBox(width: 12),
                            GenderChip(
                              label: 'Female',
                              icon: Icons.woman_outlined,
                              selected: selectedGender == Gender.female,
                              onTap: () => _selectGender(Gender.female),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SectionTitle('Photo'),
                  Center(
                    child: GestureDetector(
                      onTap: _isProcessingPhoto ? null : _showPhotoSheet,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: AppSpacing.scale(context, 225),
                            height: AppSpacing.scale(context, 225),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceLight,
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryDark.withValues(alpha: 0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              image: profileImage != null
                                  ? DecorationImage(
                                      image: FileImage(profileImage!),
                                      fit: BoxFit.cover,
                                      alignment: Alignment.center,
                                    )
                                  : null,
                            ),
                            child: profileImage == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_outlined,
                                        size: 36,
                                        color: AppColors.textOnCardMuted,
                                      ),
                                      const SizedBox(height: 6),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                          'Add photo',
                                          textAlign: TextAlign.center,
                                          style: AppText.cardBody(context).copyWith(
                                            color: Colors.black,
                                            fontSize: AppText.scale(context, 12),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                          if (_isProcessingPhoto)
                            Container(
                              width: AppSpacing.scale(context, 225),
                              height: AppSpacing.scale(context, 225),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.45),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  SecondaryButton(label: 'Get Started', icon: Icons.arrow_forward_rounded, onTap: _continue),
                ],
              ),
            ),
          ],
        ),
          ),
          if (_showGenderWarning)
            Positioned(
              top: 0,
              left: padding,
              right: padding,
              child: Material(
                elevation: 8,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                color: Colors.yellow,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    'Please select your gender',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: AppText.scale(context, 15),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
