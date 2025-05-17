import 'package:flutter/material.dart';

import 'package:gold/api/api_model.dart';
import 'package:gold/model/model.dart';

import '../widgets/custom_snackbar.dart';

class CryptoScreen extends StatefulWidget {
  final String searchQuery;

  const CryptoScreen({Key? key, required this.searchQuery}) : super(key: key);

  @override
  State<CryptoScreen> createState() => _CryptoScreenState();
}

class _CryptoScreenState extends State<CryptoScreen> {
  late Future<Gold?> _goldData;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _goldData = ApiService.fetchGoldData();
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

  // تبدیل اعداد به فرمت خوانا با جداکننده هزارگان
  String _formatNumber(dynamic number) {
    if (number is int) {
      return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    } else if (number is double) {
      return number
          .toStringAsFixed(2)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return number.toString();
  }

  // فرمت‌بندی مارکت کپ
  String _formatMarketCap(int marketCap) {
    if (marketCap >= 1000000000) {
      return '${(marketCap / 1000000000).toStringAsFixed(2)} میلیارد';
    } else if (marketCap >= 1000000) {
      return '${(marketCap / 1000000).toStringAsFixed(2)} میلیون';
    } else if (marketCap >= 1000) {
      return '${(marketCap / 1000).toStringAsFixed(2)} هزار';
    }
    return marketCap.toString();
  }

  // دریافت آیکون مناسب برای هر ارز دیجیتال
  Widget _getCryptoIcon(String nameEn) {
    // تبدیل نام ارز به حروف کوچک برای مقایسه
    String name = nameEn.toLowerCase();

    // آیکون و رنگ پیش‌فرض
    IconData iconData = Icons.currency_bitcoin;
    Color iconColor = Colors.orange;

    // تعیین آیکون و رنگ مناسب بر اساس نام ارز
    if (name.contains('bitcoin') || name.contains('btc')) {
      iconData = Icons.currency_bitcoin;
      iconColor = Colors.amber.shade700;
    } else if (name.contains('ethereum') || name.contains('eth')) {
      iconData = Icons.diamond;
      iconColor = Colors.purple.shade300;
    } else if (name.contains('tether') || name.contains('usdt')) {
      iconData = Icons.attach_money;
      iconColor = Colors.green;
    } else if (name.contains('binance') || name.contains('bnb')) {
      iconData = Icons.hexagon;
      iconColor = Colors.amber;
    } else if (name.contains('xrp') || name.contains('ripple')) {
      iconData = Icons.waves;
      iconColor = Colors.blue;
    } else if (name.contains('cardano') || name.contains('ada')) {
      iconData = Icons.blur_circular;
      iconColor = Colors.blue.shade800;
    } else if (name.contains('doge')) {
      iconData = Icons.pets;
      iconColor = Colors.amber.shade700;
    } else if (name.contains('solana') || name.contains('sol')) {
      iconData = Icons.gradient;
      iconColor = Colors.purple;
    } else if (name.contains('polkadot') || name.contains('dot')) {
      iconData = Icons.bubble_chart;
      iconColor = Colors.pink;
    } else if (name.contains('litecoin') || name.contains('ltc')) {
      iconData = Icons.monetization_on;
      iconColor = Colors.grey.shade400;
    } else if (name.contains('chainlink') || name.contains('link')) {
      iconData = Icons.link;
      iconColor = Colors.blue.shade700;
    } else if (name.contains('stellar') || name.contains('xlm')) {
      iconData = Icons.star;
      iconColor = Colors.blue.shade300;
    } else if (name.contains('uniswap') || name.contains('uni')) {
      iconData = Icons.swap_horiz;
      iconColor = Colors.pink.shade300;
    } else if (name.contains('avalanche') || name.contains('avax')) {
      iconData = Icons.landscape;
      iconColor = Colors.red.shade700;
    } else if (name.contains('polygon') || name.contains('matic')) {
      iconData = Icons.change_history;
      iconColor = Colors.purple.shade700;
    }

    // ساخت آیکون با استایل مناسب
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, size: 32, color: iconColor),
    );
  }

  // تبدیل نام ارز به سمبل مناسب برای پکیج

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
                      backgroundColor: Colors.indigo.shade400,
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
                      backgroundColor: Colors.indigo.shade400,
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
          List<Cryptocurrency> filteredCrypto = goldData.cryptocurrency;

          if (widget.searchQuery.isNotEmpty) {
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
                _buildSectionTitle('ارزهای دیجیتال'),
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

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cryptoItems.length,
      itemBuilder: (context, index) {
        final item = cryptoItems[index];
        return _buildCryptoCard(
          name: item.name,
          nameEn: item.nameEn,
          price: item.price,
          changePercent: item.changePercent,
          unit: item.unit,
          marketCap: item.marketCap,
          description: item.description,
        );
      },
    );
  }

  Widget _buildCryptoCard({
    required String name,
    required String nameEn,
    required String price,
    required double changePercent,
    required String unit,
    required int marketCap,
    required String description,
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

    // فرمت‌بندی مارکت کپ
    _formatMarketCap(marketCap);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.blue.shade50],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _getCryptoIcon(nameEn),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$formattedPrice $unit',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'IranSans',
                              ),
                            ),
                            const SizedBox(height: 4),
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
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    changeIcon,
                                    size: 14,
                                    color: changeColor,
                                  ),
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
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'YekanBakh',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nameEn,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontFamily: 'YekanBakh',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontFamily: 'YekanBakh',
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
