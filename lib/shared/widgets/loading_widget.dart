import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: Icon(Icons.qr_code, color: ColorManager.primary1));
  }
}