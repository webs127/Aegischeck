
import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:flutter/material.dart';

class HomeButtonWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  const HomeButtonWidget({
    super.key, required this.text, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: .1,
        color: ColorManager.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: ColorManager.greybackground,
                  child: Icon(
                    Icons.logout_outlined,
                    color: ColorManager.black,
                  ),
                ),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
