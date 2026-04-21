import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:flutter/material.dart';
class UsecaseSelectorWidget extends StatelessWidget {
  final bool expand;
  final bool selected;
  final String text;
  final IconData icon;
  final String description;
  final VoidCallback? ontap;
  const UsecaseSelectorWidget({
    super.key,
    this.expand = true,
    required this.text,
    this.ontap,
    required this.description,
    required this.selected,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return expand
        ? Expanded(
            child: InkWell(
              onTap: ontap,
              child: Container(
                decoration: BoxDecoration(
                  color: selected
                      ? ColorManager.primary1.withValues(alpha: .1)
                      : ColorManager.white,
                  border: Border.all(
                    color: selected ? ColorManager.primary1 : ColorManager.grey,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(icon, color: ColorManager.primary1),
                        selected
                            ? Icon(Icons.security_rounded, color: Colors.green)
                            : SizedBox(),
                      ],
                    ),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ColorManager.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : InkWell(
            onTap: ontap,
            child: Container(
              decoration: BoxDecoration(
                color: selected
                    ? ColorManager.primary1.withValues(alpha: .1)
                    : ColorManager.white,
                border: Border.all(
                  color: selected ? ColorManager.primary1 : ColorManager.grey,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(icon, color: ColorManager.primary1),
                      selected
                          ? Icon(Icons.security_rounded, color: Colors.green)
                          : SizedBox(),
                    ],
                  ),
                  Text(
                    text,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ColorManager.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
