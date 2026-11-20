import 'package:flutter/material.dart';

enum FlagType { france, england, cameroon }

/// Drapeaux dessinés en widgets (les emojis drapeaux ne s'affichent pas
/// sous Windows / Chrome).
class FlagIcon extends StatelessWidget {
  final FlagType flag;
  final double width;

  const FlagIcon({super.key, required this.flag, this.width = 26});

  double get _height => width * 2 / 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: _height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0x33000000), width: 0.6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2.5),
        child: _content(),
      ),
    );
  }

  Widget _content() {
    switch (flag) {
      case FlagType.france:
        return Row(
          children: const [
            Expanded(child: ColoredBox(color: Color(0xFF0055A4), child: SizedBox.expand())),
            Expanded(child: ColoredBox(color: Color(0xFFFFFFFF), child: SizedBox.expand())),
            Expanded(child: ColoredBox(color: Color(0xFFEF4135), child: SizedBox.expand())),
          ],
        );
      case FlagType.england:
        return Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Color(0xFFFFFFFF))),
            Center(
              child: Container(width: width, height: _height * 0.24, color: const Color(0xFFCE1124)),
            ),
            Center(
              child: Container(width: width * 0.2, height: _height, color: const Color(0xFFCE1124)),
            ),
          ],
        );
      case FlagType.cameroon:
        return Stack(
          children: [
            Row(
              children: const [
                Expanded(child: ColoredBox(color: Color(0xFF007A5E), child: SizedBox.expand())),
                Expanded(child: ColoredBox(color: Color(0xFFCE1126), child: SizedBox.expand())),
                Expanded(child: ColoredBox(color: Color(0xFFFCD116), child: SizedBox.expand())),
              ],
            ),
            Center(
              child: Icon(Icons.star_rounded, size: _height * 0.5, color: const Color(0xFFFCD116)),
            ),
          ],
        );
    }
  }
}
