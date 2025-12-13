import 'package:flutter/widgets.dart';

class CylinderClipper extends CustomClipper<Path> {
  // يحدد مدى انحناء الغطاء (كلما زادت القيمة، زاد الانحناء)
  final double curveHeight;

  CylinderClipper({this.curveHeight = 15.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    // 1. الزاوية العلوية اليسرى
    path.moveTo(0, curveHeight);

    // 2. رسم القوس العلوي
    // النقطة التحكم (Control Point) في منتصف العرض وعلى ارتفاع أقل بقليل
    path.quadraticBezierTo(
      width / 2,
      0, // نرفع النقطة التحكم قليلاً فوق الصفر للحصول على انحناء داخلي سلس
      width,
      curveHeight, // النقطة النهائية (أعلى اليمين)
    );

    // 3. الانتقال إلى أسفل اليمين بخط مستقيم
    path.lineTo(width, height - curveHeight);

    // 4. رسم القوس السفلي (عكس القوس العلوي)
    // النقطة التحكم (Control Point) في منتصف العرض وعلى ارتفاع أكبر بقليل
    path.quadraticBezierTo(
      width / 2,
      height, // نرفع النقطة التحكم قليلاً أسفل الارتفاع الكامل
      0,
      height - curveHeight, // النقطة النهائية (أسفل اليسار)
    );

    // 5. إغلاق الشكل والعودة إلى نقطة البوسء
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
