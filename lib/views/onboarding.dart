import 'package:flutter/material.dart';
import 'package:text2sign/const.dart';
import 'package:text2sign/models/onboarding_model.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:text2sign/views/role_selection.dart';
import 'package:text2sign/widgets/button.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _controller = PageController();
  bool initPage = true;
  bool lastPage = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () {
                // print("_controller");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RoleSelection()),
                );
              },
              child: Text(
                "Skip >>",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ),
          PageView.builder(
            onPageChanged: (value) {
              setState(() {
                initPage = (value == 0);
                lastPage = (value == pages.length - 1);
              });
            },
            controller: _controller,
            itemCount: pages.length,
            itemBuilder: (context, i) {
              OnboardingModel onboardingModel = pages[i];
              return Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      onboardingModel.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        onboardingModel.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(
                      onboardingModel.subTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          ),

          Container(
            alignment: Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                initPage
                    ? SizedBox(width: 100, height: 40)
                    : Button(
                        onTap: () {
                          _controller.previousPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.bounceIn,
                          );
                        },
                        text: "Back",
                      ),
                SmoothPageIndicator(
                  controller: _controller,
                  count: pages.length,
                ),
                lastPage
                    ? Button(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return RoleSelection();
                              },
                            ),
                          );
                        },
                        text: "Done",
                      )
                    : Button(
                        onTap: () {
                          _controller.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeIn,
                          );
                        },
                        text: "Next",
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
