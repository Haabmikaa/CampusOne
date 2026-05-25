import 'package:flutter/material.dart';

class WaveClipper extends CustomClipper<Path> {
  const WaveClipper({
    this.bottomInset = 40,
    this.firstEndInset = 30,
    this.secondControlInset = 65,
  });

  final double bottomInset;
  final double firstEndInset;
  final double secondControlInset;

  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - bottomInset);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - firstEndInset);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - secondControlInset);
    var secondEndPoint = Offset(size.width, size.height - bottomInset);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - bottomInset);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant WaveClipper oldClipper) {
    return bottomInset != oldClipper.bottomInset ||
        firstEndInset != oldClipper.firstEndInset ||
        secondControlInset != oldClipper.secondControlInset;
  }
}
