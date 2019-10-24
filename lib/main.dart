import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;

    var spiral = Spiral(size: size);

    return Scaffold(
      body: Center(
        child: Container(
          width: size,
          height: size,
          child: RotationTransition(
            turns: _animationController,
            child: spiral,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class Spiral extends StatefulWidget {
  final double size;
  final int seed;

  const Spiral({Key key, this.size, this.seed}) : super(key: key);

  @override
  _SpiralState createState() => _SpiralState();
}

class _SpiralState extends State<Spiral> {
  List<Offset> points;

  final Curve densityCurve = Curves.easeInExpo;
  final double granularity = 0.001;
  final double percentComplete = 0.1;
  final int numberArms = 2;
  final int starsPerTick = 20;
  math.Random _random;

  @override
  void initState() {
    super.initState();
    points = [];
    final viewSize = widget.size;
    _random = math.Random(widget.seed);

    for (int arm = 0; arm < numberArms; arm++) {
      Path path = Path();
      // start from center
      path.moveTo(viewSize / 2, viewSize / 2);

      double angle = (arm / numberArms) * math.pi * 2;
      for (double n = arm / numberArms; n <= 1; n += granularity) {
        double radius = viewSize * densityCurve.transform(n);

        // make a complete circle every 1%
        angle += (math.pi * 2) / (percentComplete * 1 / granularity);

        double originX = viewSize / 2 + radius * math.cos(angle);
        double originY = viewSize / 2 + radius * math.sin(angle);

        points += generateStarList(radius, Offset(originX, originY));

        path.lineTo(originX, originY);
      }
    }
  }

  List<Offset> generateStarList(double radius, Offset origin) {
    List<Offset> stars = [];
    for (int i = 0; i < starsPerTick; i++) {
      double spread = 0.15 * radius;

      double a = _random.nextDouble() * 2 * math.pi;
      double r = spread * math.sqrt(_random.nextDouble());

      double starX = r * math.cos(a);
      double starY = r * math.sin(a);

      stars.add(Offset(starX, starY) + origin);
    }
    return stars;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SpiralPainter(points),
    );
  }
}

class SpiralPainter extends CustomPainter {
  final List<Offset> points;

  SpiralPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawPoints(PointMode.points, points, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
