import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  OnboardingView({super.key});

  final PageController _pageController = PageController();
  final RxInt _currentPage = 0.obs;
  final RxInt _actionPage = 0.obs;

  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/images/onboarding/onboarding_1.png",
      "title": "Find Strategic\nLocations in a Flash",
      "description":
          "Explore the availability of billboards\nacross the city in real-time",
    },
    {
      "image": "assets/images/onboarding/onboarding_2.png",
      "title": "Order & Pay\nWithout Hassle",
      "description":
          "Secure your company's target advertising spots with a digital booking and payment system.",
    },
    {
      "image": "assets/images/onboarding/onboarding_3.png",
      "title": "Live Installation\nMonitor",
      "description":
          "Receive instant updates and geotagged\nphoto proof directly from the location when your ad campaign is finished running.",
    },
  ];

  void _onPageChanged(int index) {
    _currentPage.value = index;
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_currentPage.value == index) {
        _actionPage.value = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: MediaQuery.of(context).size.height * 0.35,
                    child: Image.asset(
                      _onboardingData[index]['image']!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.42,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(36),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _onboardingData[index]['title']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _onboardingData[index]['description']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF6B7280),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _onboardingData.length,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _dot(isActive: _currentPage.value == index),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Obx(() {
                      final bool isLastPage =
                          _actionPage.value == _onboardingData.length - 1;

                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeOutCubic,
                                opacity: isLastPage ? 0 : 1,
                                child: IgnorePointer(
                                  ignoring: isLastPage,
                                  child: TextButton(
                                    onPressed: () {
                                      _pageController.animateToPage(
                                        _onboardingData.length - 1,
                                        duration: const Duration(
                                          milliseconds: 420,
                                        ),
                                        curve: Curves.easeInOutCubic,
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Skip',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            AnimatedAlign(
                              duration: const Duration(milliseconds: 520),
                              curve: Curves.easeInOutCubic,
                              alignment: isLastPage
                                  ? Alignment.center
                                  : Alignment.centerRight,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 420),
                                reverseDuration: const Duration(
                                  milliseconds: 320,
                                ),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                layoutBuilder:
                                    (currentChild, previousChildren) => Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        ...previousChildren,
                                        if (currentChild != null) currentChild,
                                      ],
                                    ),
                                transitionBuilder: (child, animation) {
                                  final Animation<double> curved =
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      );
                                  final Animation<Offset> slide = Tween<Offset>(
                                    begin: const Offset(0.08, 0),
                                    end: Offset.zero,
                                  ).animate(curved);
                                  return FadeTransition(
                                    opacity: curved,
                                    child: SlideTransition(
                                      position: slide,
                                      child: ScaleTransition(
                                        scale: Tween<double>(
                                          begin: 0.97,
                                          end: 1,
                                        ).animate(curved),
                                        child: child,
                                      ),
                                    ),
                                  );
                                },
                                child: isLastPage
                                    ? SizedBox(
                                        key: const ValueKey('get_started_btn'),
                                        width: double.infinity,
                                        height: 56,
                                        child: ElevatedButton(
                                          onPressed: controller.goNext,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF33C82C,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: const Text(
                                            'Get Started',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox(
                                        key: const ValueKey('next_icon_btn'),
                                        width: 52,
                                        height: 52,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            _pageController.nextPage(
                                              duration: const Duration(
                                                milliseconds: 420,
                                              ),
                                              curve: Curves.easeInOutCubic,
                                            );
                                          },
                                          style: OutlinedButton.styleFrom(
                                            shape: const CircleBorder(),
                                            side: const BorderSide(
                                              color: Color(0xFF33C82C),
                                              width: 2,
                                            ),
                                            padding: EdgeInsets.zero,
                                          ),
                                          child: const Icon(
                                            Icons.arrow_forward,
                                            color: Color(0xFF33C82C),
                                            size: 22,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF33C82C) : const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
