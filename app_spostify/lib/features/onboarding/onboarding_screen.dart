import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/settings_provider.dart';

class _OnboardingSlideData {
  const _OnboardingSlideData({
    required this.imagePath,
    required this.titleWhite,
    required this.titleGreen,
    required this.description,
    required this.fallbackIcon,
  });

  final String imagePath;
  final String titleWhite;
  final String titleGreen;
  final String description;
  final IconData fallbackIcon;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _pageTransitionDuration = Duration(milliseconds: 700);

  static const List<_OnboardingSlideData> _slides = [
    _OnboardingSlideData(
      imagePath: 'assets/images/onboarding_1.png',
      titleWhite: 'Discover ',
      titleGreen: 'Your Music',
      description:
          'Khám phá thế giới âm nhạc đa dạng, tìm kiếm nhanh bài hát và nghệ sĩ bạn yêu thích.',
      fallbackIcon: Icons.explore_rounded,
    ),
    _OnboardingSlideData(
      imagePath: 'assets/images/onboarding_2.png',
      titleWhite: 'Create Your ',
      titleGreen: 'Playlist',
      description:
          'Tạo không gian âm nhạc của riêng bạn, lưu giữ và quản lý playlist theo tâm trạng.',
      fallbackIcon: Icons.queue_music_rounded,
    ),
    _OnboardingSlideData(
      imagePath: 'assets/images/onboarding_3.png',
      titleWhite: 'Enjoy ',
      titleGreen: 'Your Music',
      description:
          'Tận hưởng âm nhạc mọi lúc, mọi nơi với trình phát mượt mà và Equalizer sống động.',
      fallbackIcon: Icons.equalizer_rounded,
    ),
  ];

  late final PageController _pageController;
  late final AnimationController _entryController;
  late final Animation<double> _imageScaleAnimation;
  late final Animation<double> _imageFadeAnimation;
  late final Animation<Offset> _textSlideAnimation;
  late final Animation<double> _textFadeAnimation;

  int _currentPage = 0;
  double _pageOffset = 0.0;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController()..addListener(_handlePageScroll);
    _entryController = AnimationController(
      vsync: this,
      duration: _pageTransitionDuration,
    );

    _imageScaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutCubic),
      ),
    );
    _imageFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.15, 0.9, curve: Curves.easeOut),
      ),
    );

    _entryController.forward();
  }

  void _handlePageScroll() {
    if (!_pageController.hasClients) return;
    final page = _pageController.page;
    if (page != null && mounted) {
      setState(() {
        _pageOffset = page;
      });
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageScroll);
    _pageController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _entryController.forward(from: 0.0);
  }

  Future<void> _nextPage() async {
    if (_currentPage < _slides.length - 1) {
      await _pageController.nextPage(
        duration: _pageTransitionDuration,
        curve: Curves.easeInOutCubic,
      );
    } else {
      await _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);
    await context.read<SettingsProvider>().completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            right: -80,
            child: IgnorePointer(
              child: Container(
                height: 360,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.75,
                    colors: [
                      AppTheme.primaryGreen.withValues(alpha: 0.16),
                      AppTheme.darkBackground.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 14, 16, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.graphic_eq_rounded,
                                  color: AppTheme.darkBackground,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'GIAI ĐIỆU',
                                style: TextStyle(
                                  color: AppTheme.textLight,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2.2,
                                ),
                              ),
                            ],
                          ),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: isLastPage ? 0.0 : 1.0,
                            child: IgnorePointer(
                              ignoring: isLastPage || _isCompleting,
                              child: TextButton(
                                onPressed: _finishOnboarding,
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Text(
                                  'Skip',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _slides.length,
                        onPageChanged: _onPageChanged,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final delta = (_pageOffset - index).abs().clamp(0.0, 1.0);
                          final scrollScale = 1.0 - (delta * 0.12);
                          final scrollOpacity = 1.0 - (delta * 0.55);

                          return _OnboardingPageItem(
                            slide: _slides[index],
                            isActive: index == _currentPage,
                            scrollScale: scrollScale,
                            scrollOpacity: scrollOpacity,
                            imageScaleAnimation: _imageScaleAnimation,
                            imageFadeAnimation: _imageFadeAnimation,
                            textSlideAnimation: _textSlideAnimation,
                            textFadeAnimation: _textFadeAnimation,
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_slides.length, (index) {
                              final isActive = index == _currentPage;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 420),
                                curve: Curves.easeInOutCubic,
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                width: isActive ? 28 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppTheme.primaryGreen
                                      : Colors.white.withValues(alpha: 0.24),
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: isActive
                                      ? [
                                          BoxShadow(
                                            color: AppTheme.primaryGreen
                                                .withValues(alpha: 0.45),
                                            blurRadius: 8,
                                          ),
                                        ]
                                      : null,
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 26),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isCompleting ? null : _nextPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                foregroundColor: AppTheme.darkBackground,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 350),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, anim) =>
                                    FadeTransition(
                                  opacity: anim,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.2),
                                      end: Offset.zero,
                                    ).animate(anim),
                                    child: child,
                                  ),
                                ),
                                child: Text(
                                  isLastPage ? 'Get Started' : 'Next',
                                  key: ValueKey<bool>(isLastPage),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
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
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageItem extends StatelessWidget {
  const _OnboardingPageItem({
    required this.slide,
    required this.isActive,
    required this.scrollScale,
    required this.scrollOpacity,
    required this.imageScaleAnimation,
    required this.imageFadeAnimation,
    required this.textSlideAnimation,
    required this.textFadeAnimation,
  });

  final _OnboardingSlideData slide;
  final bool isActive;
  final double scrollScale;
  final double scrollOpacity;
  final Animation<double> imageScaleAnimation;
  final Animation<double> imageFadeAnimation;
  final Animation<Offset> textSlideAnimation;
  final Animation<double> textFadeAnimation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageHeight = (constraints.maxHeight * 0.56).clamp(200.0, 350.0);
        final imageWidth = math.min(
          constraints.maxWidth * 0.80,
          imageHeight * (274 / 350),
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: imageScaleAnimation,
                builder: (context, child) {
                  final scale = isActive
                      ? imageScaleAnimation.value * scrollScale
                      : scrollScale;
                  final opacity = isActive
                      ? imageFadeAnimation.value * scrollOpacity
                      : scrollOpacity;
                  return Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: scale,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: imageWidth,
                  height: imageHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.16),
                        blurRadius: 36,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      slide.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Container(
                        color: AppTheme.darkSurface,
                        alignment: Alignment.center,
                        child: Icon(
                          slide.fallbackIcon,
                          size: imageWidth * 0.36,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: constraints.maxHeight > 520 ? 30 : 18),

              SlideTransition(
                position: isActive
                    ? textSlideAnimation
                    : const AlwaysStoppedAnimation(Offset.zero),
                child: FadeTransition(
                  opacity: isActive
                      ? textFadeAnimation
                      : AlwaysStoppedAnimation(scrollOpacity),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: slide.titleWhite),
                            TextSpan(
                              text: slide.titleGreen,
                              style: const TextStyle(
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: AppTheme.textLight,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        slide.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
