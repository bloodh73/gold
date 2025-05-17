import 'package:flutter/material.dart';

class CustomSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onAction,
    String actionLabel = 'باشه',
  }) {
    // آیکون مناسب برای هر نوع اسنک‌بار
    IconData icon;
    Color backgroundColor;
    Color iconColor;

    switch (type) {
      case SnackBarType.success:
        icon = Icons.check_circle_outline;
        backgroundColor = Colors.green.shade50;
        iconColor = Colors.green.shade700;
        break;
      case SnackBarType.error:
        icon = Icons.error_outline;
        backgroundColor = Colors.red.shade50;
        iconColor = Colors.red.shade700;
        break;
      case SnackBarType.warning:
        icon = Icons.warning_amber_outlined;
        backgroundColor = Colors.amber.shade50;
        iconColor = Colors.amber.shade700;
        break;
      case SnackBarType.info:
        icon = Icons.info_outline;
        backgroundColor = Colors.blue.shade50;
        iconColor = Colors.blue.shade700;
        break;
    }

    // حذف اسنک‌بارهای قبلی
    ScaffoldMessenger.of(context).clearSnackBars();

    // نمایش اسنک‌بار جدید
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.black87,
                    fontFamily: 'YekanBakh',
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: iconColor.withOpacity(0.3), width: 1),
        ),
        elevation: 4,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        duration: duration,
        action:
            onAction != null
                ? SnackBarAction(
                  label: actionLabel,
                  textColor: iconColor,
                  onPressed: onAction,
                )
                : null,
      ),
    );
  }

  // نمایش اسنک‌بار برای رفرش شدن صفحه
  static void showRefresh({
    required BuildContext context,
    String message = 'اطلاعات با موفقیت بروزرسانی شد',
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.success,
      duration: const Duration(seconds: 2),
    );
  }

  // نمایش اسنک‌بار برای خطا
  static void showError({
    required BuildContext context,
    String message = 'خطا در دریافت اطلاعات',
    VoidCallback? onRetry,
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.error,
      duration: const Duration(seconds: 4),
      onAction: onRetry,
      actionLabel: 'تلاش مجدد',
    );
  }

  // نمایش اسنک‌بار برای هشدار
  static void showWarning({
    required BuildContext context,
    required String message,
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.warning,
      duration: const Duration(seconds: 3),
    );
  }

  // نمایش اسنک‌بار برای اطلاعات
  static void showInfo({
    required BuildContext context,
    required String message,
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.info,
      duration: const Duration(seconds: 2),
    );
  }
}

// انواع اسنک‌بار
enum SnackBarType { success, error, warning, info }
