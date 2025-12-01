import 'package:flutter/material.dart';
import '../models/genogram_member.dart';

class GenogramNodeWidget extends StatelessWidget {
  final GenogramMember member;
  final bool isSelected;
  final VoidCallback onTap;

  const GenogramNodeWidget({
    super.key,
    required this.member,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Shape based on gender
    Widget shape;
    if (member.gender == Gender.male) {
      shape = Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: member.status == LifeStatus.deceased ? Colors.grey : Colors.blue.shade100,
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.blue,
            width: isSelected ? 3 : 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      );
    } else {
      shape = Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: member.status == LifeStatus.deceased ? Colors.grey : Colors.pink.shade100,
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.pink,
            width: isSelected ? 3 : 2,
          ),
          shape: BoxShape.circle,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          shape,
          if (member.status == LifeStatus.deceased)
            CustomPaint(
              size: const Size(80, 80),
              painter: CrossPainter(),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                member.name,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${member.age} th',
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
          if (member.isClient)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;
    
    canvas.drawLine(
      Offset(0, 0),
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(0, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
