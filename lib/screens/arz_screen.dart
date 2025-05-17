import 'package:flutter/material.dart';
import 'package:gold/api/api_model.dart';
import 'package:gold/model/model.dart';

import 'package:gold/widgets/custom_snackbar.dart';
import 'package:flag/flag.dart';

class ArzScreen extends StatefulWidget {
  final String searchQuery;

  const ArzScreen({Key? key, this.searchQuery = ''}) : super(key: key);

  @override
  State<ArzScreen> createState() => _ArzScreenState();
}

class _ArzScreenState extends State<ArzScreen> {
  late Future<Gold?> _goldData;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _goldData = ApiService.fetchGoldData();
  }

  @override
  void didUpdateWidget(ArzScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      setState(() {});
    }
  }

  // تابع برای رفرش کردن داده‌ها
  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final newData = await ApiService.fetchGoldData();

      // بررسی اینکه آیا داده‌ها با موفقیت دریافت شده‌اند
      if (newData != null) {
        setState(() {
          _goldData = Future.value(newData);
          _isRefreshing = false;
        });

        // نمایش اسنک‌بار موفقیت فقط در صورت دریافت موفق داده‌ها
        CustomSnackBar.showRefresh(context: context);
      } else {
        setState(() {
          _isRefreshing = false;
        });

        // نمایش اسنک‌بار خطا در صورت عدم دریافت داده‌ها
        CustomSnackBar.showError(
          context: context,
          message: 'اطلاعات دریافت نشد. لطفا دوباره تلاش کنید.',
          onRetry: _refreshData,
        );
      }
    } catch (e) {
      setState(() {
        _isRefreshing = false;
      });

      // نمایش اسنک‌بار خطا با پیام مناسب
      CustomSnackBar.showError(
        context: context,
        message: 'خطا در بروزرسانی: ${e.toString()}',
        onRetry: _refreshData,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Gold?>(
        future: _goldData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !_isRefreshing) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'خطا: ${snapshot.error}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'YekanBakh',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _refreshData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('تلاش مجدد'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'اطلاعاتی یافت نشد',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                      fontFamily: 'YekanBakh',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لطفا اتصال اینترنت خود را بررسی کنید',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontFamily: 'YekanBakh',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _refreshData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('بارگذاری مجدد'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final goldData = snapshot.data!;

          // فیلتر کردن داده‌ها بر اساس عبارت جستجو
          List<Currency> filteredCurrency = goldData.currency;
          List<Cryptocurrency> filteredCrypto = goldData.cryptocurrency;

          if (widget.searchQuery.isNotEmpty) {
            filteredCurrency =
                goldData.currency
                    .where((item) => item.name.contains(widget.searchQuery))
                    .toList();

            filteredCrypto =
                goldData.cryptocurrency
                    .where(
                      (item) =>
                          item.name.contains(widget.searchQuery) ||
                          item.nameEn.toLowerCase().contains(
                            widget.searchQuery.toLowerCase(),
                          ),
                    )
                    .toList();
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle('قیمت ارز'),
                _buildCurrencyList(filteredCurrency),

                const SizedBox(height: 20),
                _buildSectionTitle('قیمت ارز دیجیتال'),
                _buildCryptocurrencyList(filteredCrypto),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'YekanBakh',
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _buildCurrencyList(List<Currency> currencyItems) {
    if (currencyItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'اطلاعات ارز در دسترس نیست',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontFamily: 'YekanBakh',
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            children: [
              Icon(
                Icons.currency_exchange,
                size: 16,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 8),
              const Text(
                'ارزهای خارجی',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'YekanBakh',
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: currencyItems.length,
          itemBuilder: (context, index) {
            final item = currencyItems[index];
            return _buildPriceCard(
              name: item.name,
              price: item.price.toString(),
              changePercent: item.changePercent,
              unit: item.unit,
              date: item.date,
              time: item.time,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCryptocurrencyList(List<Cryptocurrency> cryptoItems) {
    if (cryptoItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'اطلاعات ارز دیجیتال در دسترس نیست',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontFamily: 'YekanBakh',
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            children: [
              Icon(
                Icons.currency_bitcoin,
                size: 16,
                color: Colors.blue.shade800,
              ),
              const SizedBox(width: 8),
              const Text(
                'ارزهای دیجیتال',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'YekanBakh',
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cryptoItems.length,
          itemBuilder: (context, index) {
            final item = cryptoItems[index];
            return _buildPriceCard(
              name: item.name,
              price: item.price,
              changePercent: item.changePercent,
              unit: item.unit,
              date: item.date,
              time: item.time,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPriceCard({
    required String name,
    required String price,
    required double changePercent,
    required String unit,
    String? date,
    String? time,
  }) {
    final isPositive = changePercent >= 0;
    final changeColor =
        isPositive ? Colors.green.shade700 : Colors.red.shade700;
    final changeIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    // تبدیل اعداد به فرمت خوانا با جداکننده هزارگان
    String formattedPrice = price;
    try {
      final numericPrice =
          int.tryParse(price.replaceAll(',', '')) ??
          double.tryParse(price.replaceAll(',', ''));
      if (numericPrice != null) {
        formattedPrice = _formatNumber(numericPrice);
      }
    } catch (e) {
      // در صورت خطا، از همان رشته اصلی استفاده می‌کنیم
    }

    // تعیین کد پرچم مناسب برای هر ارز
    String countryCode = 'US';
    if (name.contains('دلار')) {
      countryCode = 'US';
    } else if (name.contains('یورو')) {
      countryCode = 'EU';
    } else if (name.contains('پوند')) {
      countryCode = 'GB';
    } else if (name.contains('درهم')) {
      countryCode = 'AE';
    } else if (name.contains('لیر')) {
      countryCode = 'TR';
    } else if (name.contains('ین')) {
      countryCode = 'JP';
    } else if (name.contains('یوان')) {
      countryCode = 'CN';
    } else if (name.contains('فرانک')) {
      countryCode = 'CH';
    } else if (name.contains('دلار کانادا')) {
      countryCode = 'CA';
    } else if (name.contains('دلار استرالیا')) {
      countryCode = 'AU';
    }

    // تنظیم متن‌های بروزرسانی
    String dateText = date != null && date.isNotEmpty ? date : 'امروز';
    String timeText = time != null && time.isNotEmpty ? time : '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.white,
                Colors.blue.shade50,
                Colors.blue.shade100.withOpacity(0.3),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              // اینجا می‌توانید اکشنی برای نمایش جزئیات بیشتر اضافه کنید
            },
            splashColor: Colors.blue.withOpacity(0.2),
            highlightColor: Colors.blue.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // قسمت سمت راست (در RTL) - نام و پرچم
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.blue.shade100,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Flag.fromString(
                            countryCode,
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            replacement: Icon(
                              Icons.attach_money,
                              size: 24,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'IranSans',
                            ),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 15,
                                color: Colors.grey.shade600,
                              ),
                              SizedBox(width: 3),
                              Text(
                                dateText,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontFamily: 'IranSans',
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                          if (timeText.isNotEmpty) ...[
                            SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 15,
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  timeText,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    fontFamily: 'IranSans',
                                  ),
                                ),
                                SizedBox(width: 4),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),

                  // قسمت سمت چپ (در RTL) - قیمت و تغییرات
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isPositive
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isPositive
                                        ? Colors.green.shade200
                                        : Colors.red.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(changeIcon, size: 14, color: changeColor),
                                const SizedBox(width: 4),
                                Text(
                                  '${changePercent.abs().toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: changeColor,
                                    fontFamily: 'IranSans',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$formattedPrice $unit',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IranSans',
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // تابع کمکی برای فرمت‌بندی اعداد با جداکننده هزارگان
  String _formatNumber(dynamic number) {
    if (number is int) {
      return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    } else if (number is double) {
      String formatted = number.toStringAsFixed(2);
      return formatted.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }
    return number.toString();
  }
}
