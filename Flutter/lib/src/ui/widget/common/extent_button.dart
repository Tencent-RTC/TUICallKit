import 'package:flutter/material.dart';

class ExtendButton extends StatelessWidget {
  const ExtendButton(
      {required this.imgUrl,
      this.tips = "",
      this.onTap,
      this.imgHieght = 0,
      this.imgColor,
      this.textColor,
      Key? key})
      : super(key: key);
  final String imgUrl;
  final double imgHieght;
  final Color? imgColor;
  final String tips;
  final GestureTapCallback? onTap;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap!();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: imgHieght > 0 ? imgHieght : 52.0,
            width: imgHieght > 0 ? imgHieght : 52.0,
            child: Image.asset(
              imgUrl,
              package: 'tencent_calls_uikit',
              color: imgColor,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
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
