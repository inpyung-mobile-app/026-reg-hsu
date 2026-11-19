
import 'dart:async';
import 'package:flutter/material.dart';

// 이미지, 글자, 버튼 등에 페이드인 효과를 적용하는 위젯
class FadeInObject extends StatefulWidget {
  // 화면에 표시할 내용
  final Widget child;

  // 나타나는 데 걸리는 시간
  final Duration duration;

  // 나타나기 전 기다리는 시간
  final Duration delay;

  // 위치
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  // 크기
  final double? width;
  final double? height;

  // 회전 각도
  final double rotation;

  const FadeInObject({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.delay = Duration.zero,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.width,
    this.height,
    this.rotation = 0,
  });

  @override
  State<FadeInObject> createState() => _FadeInObjectState();
}

class _FadeInObjectState extends State<FadeInObject> {
  // 처음에는 투명하게 시작
  double opacity = 0;

  // 기다리는 시간 관리
  Timer? timer;

  @override
  void initState() {
    super.initState();

    // delay 시간이 지난 후 투명도를 1로 변경
    timer = Timer(widget.delay, () {
      if (mounted) {
        setState(() {
          opacity = 1;
        });
      }
    });
  }

  @override
  void dispose() {
    // 대기 중인 타이머 정리
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      // 위치가 변경될 때 이동하는 시간
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,

      // 위치 설정
      top: widget.top,
      left: widget.left,
      right: widget.right,
      bottom: widget.bottom,

      // 크기 설정
      width: widget.width,
      height: widget.height,

      child: AnimatedOpacity(
        // 투명도 변경에 걸리는 시간
        duration: widget.duration,

        // 0은 투명, 1은 완전히 보임
        opacity: opacity,

        child: Transform.rotate(
          // 위젯 회전
          angle: widget.rotation,

          // 실제로 표시할 내용
          child: widget.child,
        ),
      ),
    );
  }
}
