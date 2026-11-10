import 'dart:math';

import 'package:flutter/material.dart';

class CircularTimer extends StatelessWidget {
	final double progress;
	final String timeText;
	final Color timerColor;
	final double size;

	const CircularTimer({
		super.key,
		required this.progress,
		required this.timeText,
		required this.timerColor,
		this.size = 240,
	});

	@override
	Widget build(BuildContext context) {
		return SizedBox(
			width: size,
			height: size,
			child: Stack(
				alignment: Alignment.center,
				children: [
					CustomPaint(
						size: Size(size, size),
						painter: _TimerPainter(
							progress: progress,
							color: timerColor,
						),
					),
					Text(
						timeText,
						style: TextStyle(
							fontSize: size * 0.2,
							fontWeight: FontWeight.bold,
							color: Colors.white,
						),
					),
				],
			),
		);
	}
}

class _TimerPainter extends CustomPainter {
	final double progress;
	final Color color;

	_TimerPainter({required this.progress, required this.color});

	@override
	void paint(Canvas canvas, Size size) {
		final center = Offset(size.width / 2, size.height / 2);
		final radius = size.width / 2 - 12;

		final trackPaint = Paint()
			..color = color.withValues(alpha: 0.15)
			..style = PaintingStyle.stroke
			..strokeWidth = 14;

		canvas.drawCircle(center, radius, trackPaint);

		final progressPaint = Paint()
			..color = color
			..style = PaintingStyle.stroke
			..strokeCap = StrokeCap.round
			..strokeWidth = 14;

		final sweepAngle = 2 * pi * progress;
		canvas.drawArc(
			Rect.fromCircle(center: center, radius: radius),
			-pi / 2,
			sweepAngle,
			false,
			progressPaint,
		);
	}

	@override
	bool shouldRepaint(covariant _TimerPainter oldDelegate) {
		return oldDelegate.progress != progress || oldDelegate.color != color;
	}
}
