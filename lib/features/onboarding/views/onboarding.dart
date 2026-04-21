import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:aegischeck/features/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:aegischeck/features/onboarding/widgets/counter_widget.dart';
import 'package:aegischeck/shared/components/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: AppBar(
        backgroundColor: ColorManager.background,
        automaticallyImplyLeading: false,
        title: Row(
          spacing: 8,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ColorManager.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.qr_code, color: ColorManager.white,),
            ),
            Text(
              "AegisCheck",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: ColorManager.primary),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 490,
                child: PageView.builder(
                  controller: context
                      .read<OnboardingViewModel>()
                      .pageController,
                  itemCount: context.read<OnboardingViewModel>().length,
                  onPageChanged: context
                      .read<OnboardingViewModel>()
                      .onPageChanged,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: .5,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Selector<OnboardingViewModel, OnboardingObject>(
                          selector: (_, vm) => vm.onboardingObject,
                          builder: (context, onboardingObject, child) {
                            return Column(
                              children: [
                                SizedBox(
                                  //color: Colors.redAccent,
                                  width: size.width,
                                  //height: size.height / 2.2,
                                  child: SvgPicture.asset(
                                    onboardingObject.imagePath,
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentGeometry.centerLeft,
                                  child: Text(
                                    onboardingObject.textHeader,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  onboardingObject.textDescription,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 15),
              Row(
                spacing: 10,
                children: [
                  CounterWidget(),
                  CustomButton(
                    onPressed: context.watch<OnboardingViewModel>().check()
                        ? () {context.read<OnboardingViewModel>().nextScreen(context);}
                        : () {
                            context.read<OnboardingViewModel>().nextPage();
                          },
                    child: context.watch<OnboardingViewModel>().check()
                        ? Row(
                            spacing: 5,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Get Started",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          )
                        : Row(
                            spacing: 5,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Continue",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                spacing: 10,
                children: [
                  CustomButton(
                    color: Colors.white,
                    child: Text(
                      "Login",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  CustomButton(
                    color: Colors.white,
                    child: Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
