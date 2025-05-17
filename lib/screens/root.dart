import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:gold/const/constants.dart';
import 'package:gold/screens/arz_screen.dart';
import 'package:gold/screens/gold_screen.dart';
import 'package:gold/screens/crypto_screen.dart';
import 'package:gold/utils/update_checker.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int bottomIndex = 0;
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Widget> page() {
    return [
      ArzScreen(searchQuery: _searchQuery),
      GoldScreen(searchQuery: _searchQuery),
      CryptoScreen(searchQuery: _searchQuery),
    ];
  }

  // لیست آیکون‌ها برای نوار پایین
  List<IconData> iconList = [
    Icons.currency_exchange,
    Icons.monetization_on,
    Icons.currency_bitcoin,
  ];

  // لیست عناوین برای نمایش در نوار پایین
  List<String> tabTitles = ['ارز', 'طلا', 'ارز دیجیتال'];

  // عناوین نوار بالا
  List<String> appBarTitle = [
    'قیمت لحظه ای ارز',
    'قیمت لحظه ای طلا',
    'قیمت لحظه ای ارز دیجیتال',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            _showSearch
                ? Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'جستجو...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontFamily: 'YekanBakh',
                      ),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear, color: Constants.blackColor),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                            _showSearch = false;
                          });
                        },
                      ),
                    ),
                    style: TextStyle(
                      color: Constants.blackColor,
                      fontFamily: 'YekanBakh',
                      fontSize: 18.0,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        appBarTitle[bottomIndex],
                        style: TextStyle(
                          color: Constants.blackColor,
                          fontFamily: 'YekanBakh',
                          fontSize: 24.0,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.search,
                              color: Constants.blackColor,
                              size: 30.0,
                            ),
                            onPressed: () {
                              setState(() {
                                _showSearch = true;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: IndexedStack(index: bottomIndex, children: page()),
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: tabTitles.length,
        tabBuilder: (int index, bool isActive) {
          // ساخت ویجت سفارشی برای هر تب
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // آیکون
              Icon(
                iconList[index],
                size: 24,
                color:
                    isActive
                        ? Constants.primaryColor
                        : Colors.black.withOpacity(0.5),
              ),
              const SizedBox(height: 4),
              // متن
              Text(
                tabTitles[index],
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'YekanBakh',
                  color:
                      isActive
                          ? Constants.primaryColor
                          : Colors.black.withOpacity(0.5),
                ),
              ),
            ],
          );
        },
        splashColor: Constants.primaryColor,
        activeIndex: bottomIndex,
        gapLocation: GapLocation.none,
        notchSmoothness: NotchSmoothness.softEdge,
        onTap: (index) {
          setState(() {
            bottomIndex = index;
          });
        },
      ),
    );
  }
}
