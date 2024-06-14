import 'package:flutter/material.dart';

class ExtendButton extends StatelessWidget {
  const ExtendButton(
      {required this.imgUrl,
      this.tips = "",
      this.onTap,
      this.imgHeight = 0,
      this.imgOffsetX = 0,
      this.imgOffsetY = 0,
      this.imgColor,
      this.textColor,
      this.duration = const Duration(milliseconds: 200),
      this.userAnimation = false,
      Key? key})
      : super(key: key);
  final String imgUrl;
  final double imgHeight;
  final Color? imgColor;
  final double imgOffsetX;
  final double imgOffsetY;
  final String tips;
  final GestureTapCallback? onTap;
  final Color? textColor;
  final bool? userAnimation;
  final Duration duration;

  Widget _buildImageView() {
    return userAnimation!
        ? AnimatedContainer(
            duration: duration,
            height: imgHeight > 0 ? imgHeight : 52.0,
            width: imgHeight > 0 ? imgHeight : 52.0,
            child: Image.asset(
              imgUrl,
              package: 'tencent_calls_uikit',
              color: imgColor,
            ),
          )
        : SizedBox(
            height: imgHeight > 0 ? imgHeight : 52.0,
            width: imgHeight > 0 ? imgHeight : 52.0,
            child: Image.asset(
              imgUrl,
              package: 'tencent_calls_uikit',
              color: imgColor,
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap!();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: Offset(imgOffsetX, imgOffsetY),
            child: _buildImageView(),
          ),
          Container(
            width: 100,
            height: 15,
            margin: const EdgeInsets.only(top: 10),
            alignment: Alignment.center,
            child: Text(
              tips,
              style: TextStyle(fontSize: 12, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
