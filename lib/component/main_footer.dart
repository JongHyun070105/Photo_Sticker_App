import 'package:flutter/material.dart';

typedef OnEmoticonTap = void Function(int id);

class MainFooter extends StatelessWidget {
  final OnEmoticonTap onEmoticonTap;

  const MainFooter({required this.onEmoticonTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      color: Colors.white.withValues(alpha: 0.9),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            7,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GestureDetector(
                onTap: () => onEmoticonTap(index + 1),
                child: Image.asset('asset/img/emoticon_${index + 1}.png'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
