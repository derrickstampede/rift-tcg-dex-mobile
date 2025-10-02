import 'package:flutter/material.dart';

class CardRarityBadge extends StatelessWidget {
  const CardRarityBadge({
    super.key,
    required String rarity,
  }) : _rarity = rarity;

  final String _rarity;

  @override
  Widget build(BuildContext context) {
    LinearGradient? gradient;
    Color color = Colors.black;

    switch (_rarity) {
      case 'P':
        gradient = const LinearGradient(
          colors: [Color(0xff125c84), Color(0xff58949c), Color(0xff125c84)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
        break;
      // case 'TR':
      //   gradient = const LinearGradient(
      //     colors: [Color(0xffBF953F), Color(0xffFCF6BA), Color(0xffBF953F)],
      //     begin: Alignment.centerLeft,
      //     end: Alignment.centerRight,
      //   );
      //   break;
      // case 'SP':
      //   gradient = const LinearGradient(
      //     colors: [Color(0xffB86B77), Color(0xffD8ABB1), Color(0xffB86B77)],
      //     begin: Alignment.centerLeft,
      //     end: Alignment.centerRight,
      //   );
      //   break;
      case 'L':
        gradient = const LinearGradient(
          colors: [Color(0xff284e74), Color(0xff4088a9), Color(0xff284e74)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
        color = Colors.grey.shade300;
        break;
      case 'SCR':
        gradient = const LinearGradient(
          colors: [Color(0xffBF953F), Color(0xffFCF6BA), Color(0xffBF953F)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
        break;
      case 'SR':
        gradient = const LinearGradient(
          colors: [Color(0xffEDF1F4), Color(0xffC3CBDC), Color(0xffEDF1F4)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
        break;
      case 'R':
        gradient = const LinearGradient(
          colors: [Color(0xff80501a), Color(0xffe0982d), Color(0xff80501a)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
        break;
      case 'UC':
        gradient = const LinearGradient(
          colors: [Color(0xff7bc198), Color(0xffa2ddbc), Color(0xff7bc198)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
        break;
      case 'C':
        gradient = const LinearGradient(
          colors: [Color(0xff212121), Color(0xff404040), Color(0xff212121)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
        color = Colors.white;
        break;
      case 'E':
        gradient = const LinearGradient(
          colors: [Color(0xff212121), Color(0xff404040), Color(0xff212121)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
        color = Colors.white;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: gradient,
      ),
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
      child: Text(
        _rarity,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
