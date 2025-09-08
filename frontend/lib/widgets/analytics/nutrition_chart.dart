import 'package:flutter/cupertino.dart';
import '../../main.dart';
import '../../services/analytics_service.dart';

class NutritionChart extends StatelessWidget {
  final List<NutritionTrendData> data;
  final String title;
  final String metric;
  final Color color;
  final double height;

  const NutritionChart({
    super.key,
    required this.data,
    required this.title,
    required this.metric,
    required this.color,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: height,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.chart_bar,
              size: 48,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    final maxValue = data
        .map((d) => d.values[metric] ?? 0.0)
        .reduce((a, b) => a > b ? a : b);
    
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: ChartPainter(
                data: data,
                metric: metric,
                maxValue: maxValue,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<NutritionTrendData> data;
  final String metric;
  final double maxValue;
  final Color color;

  ChartPainter({
    required this.data,
    required this.metric,
    required this.maxValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || maxValue <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    
    final stepWidth = size.width / (data.length - 1);
    
    // Start fill path from bottom
    fillPath.moveTo(0, size.height);
    
    for (int i = 0; i < data.length; i++) {
      final value = data[i].values[metric] ?? 0.0;
      final x = i * stepWidth;
      final y = size.height - (value / maxValue * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    
    // Complete fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    
    // Draw fill area first
    canvas.drawPath(fillPath, fillPaint);
    
    // Draw line on top
    canvas.drawPath(path, paint);
    
    // Draw data points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    for (int i = 0; i < data.length; i++) {
      final value = data[i].values[metric] ?? 0.0;
      final x = i * stepWidth;
      final y = size.height - (value / maxValue * size.height);
      
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
      canvas.drawCircle(
        Offset(x, y), 
        4, 
        Paint()
          ..color = CupertinoColors.white
          ..style = PaintingStyle.fill
      );
      canvas.drawCircle(Offset(x, y), 2, pointPaint);
    }
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    return oldDelegate.data != data || 
           oldDelegate.maxValue != maxValue ||
           oldDelegate.color != color;
  }
}

class ProgressRing extends StatelessWidget {
  final double progress;
  final double size;
  final Color color;
  final double strokeWidth;
  final Widget? child;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.color = AppColors.primary,
    this.strokeWidth = 8,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Background circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: CupertinoColors.systemGrey5,
                width: strokeWidth,
              ),
            ),
          ),
          // Progress arc
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: ProgressRingPainter(
                progress: progress.clamp(0.0, 1.0),
                color: color,
                strokeWidth: strokeWidth,
              ),
            ),
          ),
          // Center content
          if (child != null)
            Center(child: child!),
        ],
      ),
    );
  }
}

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Start from top (-π/2) and draw clockwise
    const startAngle = -3.14159 / 2;
    final sweepAngle = 2 * 3.14159 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}