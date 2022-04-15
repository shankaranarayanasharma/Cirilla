import 'package:cirilla/constants/assets.dart';
import 'package:cirilla/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:ui/painter/zoom_painter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'widgets/zoom_animation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key, this.color, this.loading}) : super(key: key);

  final Color? color;
  final bool? loading;

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  Size size = Size.zero;
  late AnimationController _controller;
  late ZoomAnimation _animation;
  AnimationStatus _status = AnimationStatus.forward;

  final spinkit = SpinKitFadingCube(
    size: 20,
    itemBuilder: (BuildContext context, int index) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: index.isEven ? const Color(0xff42210b) : const Color(0xff42210b),
        ),
      );
    },
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )
      ..addStatusListener((AnimationStatus status) {
        setState(() {
          _status = status;
        });
      })
      ..addListener(() {
        setState(() {});
      });
    _animation = ZoomAnimation(_controller);
  }

  @override
  void didChangeDependencies() {
    setState(() {
      size = MediaQuery.of(context).size;
    });
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant SplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.loading! && _controller.status != AnimationStatus.forward) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_status == AnimationStatus.completed) return Container();
    return Stack(children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CustomPaint(
            painter: ZoomPainter(color: widget.color!, zoomSize: _animation.zoomSize.value * size.width),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: itemPaddingExtraLarge),
          child: Align(
            alignment: Alignment.center,
            child: Opacity(
              opacity: _animation.textOpacity.value,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Center(child: Image.asset(Assets.logo, width: 200, height: 200, fit: BoxFit.fitWidth)),
                  Container(
                      margin: const EdgeInsets.only(top: 100),
                      alignment: Alignment.bottomCenter,
                      child: spinkit)
                ],
              ),
            ),
          ),
        ),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

}
