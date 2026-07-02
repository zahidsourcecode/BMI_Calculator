import 'dart:io';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../Services/image_helper.dart';
import '../constants.dart';
import '../Widgets/app_ui.dart';
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

      final picked = File(pickedFile.path);
      setState(() {
        profileImage = picked;
        _isProcessingPhoto = true;
      });

      await Future<void>.delayed(Duration.zero);

      final startedAt = DateTime.now();
      try {
        final normalized = await ImageHelper.normalizeForDisplay(picked, source);
        if (!mounted) return;
        setState(() => profileImage = normalized);
      } catch (_) {
        if (!mounted) return;
        setState(() => profileImage = picked);
      } finally {
        const minLoader = Duration(milliseconds: 500);
        final elapsed = DateTime.now().difference(startedAt);
        if (elapsed < minLoader) {
          await Future.delayed(minLoader - elapsed);
        }
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
          profileImage: profileImage,
        ),
      ),
    );
  }

  void _showPhotoSheet() {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
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
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.photo_camera_outlined, color: colors.primary),
              title: const Text('Take photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: colors.primary),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (profileImage != null)
              ListTile(
                leading: Icon(Icons.delete_outline, color: colors.danger),
                title: Text('Remove photo', style: TextStyle(color: colors.danger)),
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
    final photoSize = AppSpacing.photoSize(context);
    final logoSize = AppSpacing.scale(context, 68);
    final colors = context.colors;

    return AppScaffold(
      actions: [
        IconButton(
          tooltip: 'Home',
          icon: Icon(Icons.home_rounded, color: colors.textPrimary),
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
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(AppSpacing.scale(context, 6)),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: colors.border, width: 0.5),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.primary.withValues(alpha: 0.12),
                                  blurRadius: AppSpacing.scale(context, 24),
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/icon/appIcon.png',
                              width: logoSize,
                              height: logoSize,
                            ),
                          ),
                        ),
                        AppSpacing.gap(context, 12),
                        Text('Your BMI', style: AppText.display(context), textAlign: TextAlign.center),
                        AppSpacing.gap(context, 6),
                        Text(
                          'Understand your body metrics in few steps.',
                          style: AppText.body(context),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.gap(context, 16),
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
                                  AppSpacing.gapH(context, 12),
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
                        AppSpacing.gap(context, 16),
                        const SectionTitle('Photo (Optional)'),
                        Center(
                          child: GestureDetector(
                            onTap: _isProcessingPhoto ? null : _showPhotoSheet,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                _PhotoCircle(
                                  size: photoSize,
                                  profileImage: profileImage,
                                  isBlurred: _isProcessingPhoto,
                                ),
                                if (_isProcessingPhoto)
                                  Positioned.fill(
                                    child: Center(
                                      child: _PhotoLoadingOverlay(size: photoSize),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        AppSpacing.gap(context, 16),
                        SecondaryButton(
                          label: 'Get Started',
                          icon: Icons.arrow_forward_rounded,
                          onTap: _continue,
                        ),
                      ],
                    ),
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

class _PhotoLoadingOverlay extends StatelessWidget {
  const _PhotoLoadingOverlay({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return IgnorePointer(
      child: Container(
      width: size,
      height: size,
      margin: EdgeInsets.only(bottom: AppSpacing.scale(context, 10)),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.button.withValues(alpha: 0.82),
            colors.primaryDark.withValues(alpha: 0.72),
          ],
        ),
        border: Border.all(color: colors.textPrimary.withValues(alpha: 0.85), width: 2),
        boxShadow: [
          BoxShadow(
            color: colors.primaryDark.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: AppSpacing.scale(context, 36),
            height: AppSpacing.scale(context, 36),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: colors.textPrimary,
              backgroundColor: colors.textPrimary.withValues(alpha: 0.2),
            ),
          ),
          AppSpacing.gap(context, 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.scale(context, 16)),
            child: Text(
              'Loading image...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: AppText.scale(context, 13),
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _PhotoCircle extends StatelessWidget {
  const _PhotoCircle({
    required this.size,
    required this.profileImage,
    this.isBlurred = false,
  });

  final double size;
  final File? profileImage;
  final bool isBlurred;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final circle = Container(
      width: size,
      height: size,
      margin: EdgeInsets.only(bottom: AppSpacing.scale(context, 10)),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.surfaceLight,
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.primaryDark.withValues(alpha: 0.1),
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
                  size: AppSpacing.icon(context, 36),
                  color: colors.isDark ? colors.textPrimary : colors.textOnCardMuted,
                ),
                AppSpacing.gap(context, 6),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.scale(context, 12)),
                  child: Text(
                    'Add photo',
                    textAlign: TextAlign.center,
                    style: AppText.cardBody(context).copyWith(
                      color: colors.isDark ? colors.textPrimary : colors.textOnCard,
                      fontSize: AppText.scale(context, 12),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          : null,
    );

    if (!isBlurred) return circle;

    return ClipOval(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: circle,
      ),
    );
  }
}
