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
  SpiralPainter starField;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        // /* This is a series of random arcs. */
        // child: Container(
        //   width: size,
        //   height: size,
        //   decoration: ShapeDecoration(
        //     color: Colors.transparent,
        //     // border: Border(bottom: BorderSide(color: Colors.white, width: 2.0)),
        //     shape: CircleBorder(
        //       side: BorderSide(color: Colors.white, width: 2.0),
        //     ),
        //   ),
        // ),
        child: Container(
          color: Colors.black,
          width: size,
          height: size,
          child: RotationTransition(
            turns: _animationController,
            child: Spiral(size: size),
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

  const Spiral({Key key, this.size}) : super(key: key);

  @override
  _SpiralState createState() => _SpiralState();
}

class _SpiralState extends State<Spiral> {
  List<Offset> points;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SpiralPainter(),
    );
  }
}

class SpiralPainter extends CustomPainter {
  final Curve densityCurve = Curves.easeInExpo;
  final double granularity = 0.001;
  final double percentComplete = 0.1;
  final int numberArms = 2;
  final int starsPerTick = 20;

  final math.Random _random;

  SpiralPainter({int seed}) : _random = math.Random(seed);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final viewSize = size.width;

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

        List stars = generateStarList(radius, Offset(originX, originY));
        canvas.drawPoints(PointMode.points, stars, paint);

        path.lineTo(originX, originY);
      }

      // draw path for reference. Not normally needed.
      //canvas.drawPath(path, paint);
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
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // TODO: what's a reasonable sweep angle?
    double sweepAngle = math.pi * 2 / 3;

    // create path
    Path path = Path();
    // for oval/rect sizes starting very small and increasing to size of square viewport (i.e., width by width)
    for (double i = 0; i < 1.0; i += 0.1) {
      Rect rect = Rect.fromCenter(
        center: Offset(size.width / 2, size.width / 2),
        width: size.width * i,
        height: size.width * i,
      );

      path.addArc(rect, i * math.pi * 2, sweepAngle);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
