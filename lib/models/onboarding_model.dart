class OnboardingModel {
  final String title;
  final String subTitle;
  final String image;

  OnboardingModel({
    required this.title,
    required this.subTitle,
    required this.image,
  });
}

List<OnboardingModel> pages = [
  OnboardingModel(
    title: "Welcome to Your Smart Assistant",
    subTitle:
        "A smart app that supports communication through sign language and sound awareness.",
    image: "assets/onboarding/onboarding_welcome.png",
  ),
  OnboardingModel(
    title: "Understand Speech Better",
    subTitle:
        "Translate spoken conversations into accessible communication support.",
    image: "assets/onboarding/onboarding_translate.png",
  ),
  OnboardingModel(
    title: "Detect Important Sounds",
    subTitle:
        "Know when important sounds happen around you with instant smart alerts.",
    image: "assets/onboarding/onboarding_safe_connected.png",
  ),
  OnboardingModel(
    title: "More Confidence Every Day",
    subTitle: "Communicate, stay alert, and live more independently.",
    image: "assets/onboarding/onboarding_detect_sounds.png",
  ),
];
