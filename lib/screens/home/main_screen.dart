// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../side_menu.dart'; // Add this import
void main() {
  runApp(const ElefApp());
}

class ElefApp extends StatelessWidget {
  const ElefApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'الف - Elef',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF513E35),
        scaffoldBackgroundColor: const Color(0xFFF3E7DF),
        textTheme: GoogleFonts.cairoTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
      ),
      home: const MainScreen(),
      locale: const Locale('ar', 'SA'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;
  String _selectedCategory = 'نساء';
  final List<String> _categories = ['نساء', 'أطفال'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: 3, vsync: this);

    // Sync PageView with TabController
    _pageController.addListener(() {
      if (_pageController.page != null) {
        _tabController.animateTo(_pageController.page!.round());
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E7DF),
      endDrawer: const SideMenu(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Builder( // Wrap with Builder
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF513E35)),
            onPressed: () {
              Scaffold.of(context).openEndDrawer(); // Open right-side drawer
            },
          ),
        ),
        title: DropdownButton<String>(
          value: _selectedCategory,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF513E35)),
          elevation: 0,
          style: const TextStyle(
            color: Color(0xFF513E35),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
          underline: Container(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue!;
            });
          },
          items: _categories.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Color(0xFF513E35)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF513E35)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Custom Tab Bar with animation
          Container(
            color: Colors.white,
            child: Row(
              children: [
                const SizedBox(width: 16), // Left margin
                Stack(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTab('الرئيسية', 0),
                        _buildTab('الأقسام', 1),
                        _buildTab('مخصص لك', 2),
                      ],
                    ),
                    // Animated underline
                    AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, child) {
                        double rightPosition = 0;

                        // Calculate position from right (RTL)
                        if (_tabController.index == 2) {
                          rightPosition = 160; // Rightmost position (under الرئيسية)
                        } else if (_tabController.index == 1) {
                          rightPosition = 80; // Middle position (under الأقسام)
                        } else if (_tabController.index == 1) {
                          rightPosition = 0; // Leftmost position (under مخصص لك)
                        }

                        return AnimatedPositioned(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          bottom: 0,
                          right: rightPosition, // Changed from left to right
                          child: Container(
                            width: 80,
                            height: 2,
                            color: const Color(0xFF513E35),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const Spacer(), // This pushes tabs to the left (which appears right in RTL)
              ],
            ),
          ),
          // Swipeable content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _tabController.index = index;
                });
              },
              children: [
                _buildHomeTab(),
                _buildCategoriesTab(),
                _buildForYouTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.index = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        width: 80, // Fixed width for each tab
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? const Color(0xFF513E35) : const Color(0xFF999999),
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Main Hero Image
        Container(
          height: 400,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            image: const DecorationImage(
              image: AssetImage('assets/images/summer_hero.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
              const Positioned(
                bottom: 40,
                right: 20,
                child: Text(
                  'ملابس الصيف',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // New In Section
        _buildSectionTitle('جديد لدينا'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildNewInItem('إطلالات جديدة', Icons.star),
              _buildNewInItem('ماركات فاخرة', Icons.diamond),
              _buildNewInItem('ملابس الصيف ', Icons.wb_sunny),
              _buildNewInItem('إكسسوارات', Icons.watch),
            ],
          ),
        ),

        // Accessories Banner
        Container(
          margin: const EdgeInsets.all(16),
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFFE8E0D5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 20,
                top: 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'إكسسوارات',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF513E35),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'لإطلالة مثالية',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF513E35),
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                left: 20,
                bottom: 20,
                child: Icon(
                  Icons.arrow_back,
                  color: Color(0xFF513E35),
                ),
              ),
            ],
          ),
        ),

        // Selling Fast Section
        _buildSectionTitle('الأكثر مبيعاً'),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            itemBuilder: (context, index) {
              return _buildProductCard(index);
            },
          ),
        ),

        // Explore Products Section
        _buildSectionTitle('اكتشفي منتجاتنا'),
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildExploreItem('فساتين', Icons.checkroom),
              _buildExploreItem('حقائب', Icons.shopping_bag),
              _buildExploreItem('أحذية', Icons.directions_walk),
              _buildExploreItem('مجوهرات', Icons.diamond),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF513E35),
        ),
      ),
    );
  }

  Widget _buildNewInItem(String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 60,
            color: const Color(0xFF513E35),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF513E35),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(int index) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.image,
                size: 60,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'فستان صيفي',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            '299 ر.س',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF513E35),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreItem(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 30,
            color: const Color(0xFF513E35),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.arrow_back_ios,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
  Widget _buildCategoriesTab() {
    final categories = [
      {'title': 'جديد', 'image': 'assets/images/new_in.png'},
      {'title': 'ملابس', 'image': 'assets/images/clothing.png'},
      {'title': 'أحذية', 'image': 'assets/images/new_in.png'},
      {'title': 'ماركات', 'image': 'assets/images/clothing.png'},
      {'title': 'الأكثر رواجاً', 'image': 'assets/images/accessories.png'},
      {'title': 'إكسسوارات', 'image': 'assets/images/accessories.png'},
      {'title': 'ملابس رياضية', 'image': 'assets/images/accessories.png'},
      {'title': 'العناية والجمال', 'image': 'assets/images/new_in.png'},
      {'title': 'أحذية رياضية', 'image': 'assets/images/clothing.png'},
      {'title': 'تفصيل', 'image': 'assets/images/new_in.png'},
      /*
      {'title': 'أحذية', 'image': 'assets/images/shoes.jpg'},
      {'title': 'ماركات', 'image': 'assets/images/brands.jpg'},
      {'title': 'الأكثر رواجاً', 'image': 'assets/images/trending.jpg'},
      {'title': 'إكسسوارات', 'image': 'assets/images/accessories.png'},
      {'title': 'ملابس رياضية', 'image': 'assets/images/activewear.jpg'},
      {'title': 'العناية والجمال', 'image': 'assets/images/grooming.jpg'},
      {'title': 'أحذية رياضية', 'image': 'assets/images/trainers.jpg'},
      {'title': 'تفصيل', 'image': 'assets/images/tailoring.jpg'},
      */

    ];

    return Container(
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // First promotional banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(1),
            ),
            child: const Center(
              child: Text(
                'احصلي على خصم يصل إلى 30%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Second promotional banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFCDDC39),

              borderRadius: BorderRadius.circular(1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'أكبر تخفيضات الصيف',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'الآن خصم يصل إلى 70%',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Categories list
          ...categories.map((category) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8), // Slight gray background
                borderRadius: BorderRadius.circular(1),
              ),
              child: Row(
                children: [
                  // Category title on the left
                  Expanded(
                    child: Text(
                      category['title']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // Category image on the right
                  Container(
                    width: 100,
                    height: 100,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(1),
                      child: Image.asset(
                        category['image']!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildForYouTab() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 300,
            width: double.infinity,
            color: Colors.grey[100],
            child: const Icon(
              Icons.people,
              size: 100,
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  'لنجعلها شخصية',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'سجلي الدخول للحصول على أفضل اختياراتك',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: const Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}