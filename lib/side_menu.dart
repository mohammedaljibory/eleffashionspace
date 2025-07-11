// side_menu.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../screens/auth/signin_screen.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  // Track dark mode state
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    // Get auth service to check authentication status
    final authService = Provider.of<AuthService>(context);
    final isSignedIn = authService.isAuthenticated;
    final userName = authService.currentUser?.name ?? '';

    return Drawer(
      // Set drawer width to 85% of screen width
      width: MediaQuery.of(context).size.width * 0.85,

      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Header section with sign in/user info
            _buildHeader(isSignedIn, userName),

            // Main menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Home menu item
                  _buildMenuItem(
                    icon: Icons.home_outlined,
                    title: 'الرئيسية',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to home
                    },
                  ),

                  // Bag menu item
                  _buildMenuItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'الحقيبة',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to bag/cart
                    },
                  ),

                  // Saved items with heart icon
                  _buildMenuItem(
                    iconWidget: const Icon(
                      CupertinoIcons.heart_fill,
                      color: Colors.red,
                      size: 24,
                    ),
                    title: 'العناصر المحفوظة',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to saved items
                    },
                  ),

                  // My Account - Only show when signed in
                  if (isSignedIn)
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'حسابي',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to account
                      },
                    ),

                  // My Orders - Only show when signed in
                  if (isSignedIn)
                    _buildMenuItem(
                      icon: Icons.receipt_long_outlined,
                      title: 'طلباتي',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to orders
                      },
                    ),

                  // Delivery Addresses - Only show when signed in
                  if (isSignedIn)
                    _buildMenuItem(
                      icon: Icons.location_on_outlined,
                      title: 'عناوين التوصيل',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to addresses
                      },
                    ),

                  // App Settings
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'إعدادات التطبيق',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to settings
                    },
                  ),

                  // Help & FAQs
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'المساعدة والأسئلة الشائعة',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to help
                    },
                  ),

                  const SizedBox(height: 20),

                  // Dark mode toggle
                  _buildDarkModeToggle(),

                  const SizedBox(height: 30),

                  // More section
                  _buildSectionTitle('المزيد من الف'),

                  // Gift vouchers
                  _buildTextMenuItem(
                    title: 'قسائم الهدايا',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to gift vouchers
                    },
                  ),

                  // Contact Us
                  _buildTextMenuItem(
                    title: 'اتصل بنا',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to contact
                    },
                  ),

                  const SizedBox(height: 30),

                  // Tell us section
                  _buildSectionTitle('أخبرنا برأيك'),

                  // Help improve
                  _buildTextMenuItem(
                    title: 'ساعد في تحسين التطبيق',
                    onTap: () {
                      Navigator.pop(context);
                      // Open feedback
                    },
                  ),

                  // Rate app
                  _buildTextMenuItem(
                    title: 'قيم التطبيق',
                    onTap: () {
                      Navigator.pop(context);
                      // Open app store for rating
                    },
                  ),

                  const SizedBox(height: 30),

                  // Sign out button (only show when signed in)
                  if (isSignedIn) ...[
                    _buildSignOutButton(),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build header section based on sign-in state
  Widget _buildHeader(bool isSignedIn, String userName) {
    if (isSignedIn) {
      // Signed in header with background image
      return Container(
        width: double.infinity,
        height: 180,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/side_menu.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'مرحباً، $userName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Consumer<AuthService>(
                builder: (context, auth, child) {
                  final user = auth.currentUser;
                  if (user != null && user.phoneNumber.isNotEmpty) {
                    return Text(
                      user.phoneNumber,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      );
    } else {
      // Not signed in header
      return Container(
        width: double.infinity,
        height: 220,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/side_menu.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'الف',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF513E35),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'احفظ، تسوق واعرض طلباتك',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Sign in button
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close drawer first
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignInScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // Build menu item with icon
  Widget _buildMenuItem({
    IconData? icon,
    Widget? iconWidget,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      // Use custom icon widget if provided, otherwise use IconData
      leading: iconWidget ?? Icon(
        icon,
        color: Colors.black87,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
      // Add padding for better spacing
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  // Build dark mode toggle switch
  Widget _buildDarkModeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(
            Icons.nightlight_outlined,
            color: Colors.black87,
            size: 24,
          ),
          const SizedBox(width: 16),
          const Text(
            'الوضع الليلي',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          // Custom switch to match iOS style
          CupertinoSwitch(
            value: isDarkMode,
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
              });
              // TODO: Implement dark mode logic here
            },
            activeColor: Colors.black87,
          ),
        ],
      ),
    );
  }

  // Build section title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Build text-only menu item
  Widget _buildTextMenuItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  // Build sign out button
  Widget _buildSignOutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.red.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextButton(
          onPressed: () async {
            // Show confirmation dialog
            final shouldSignOut = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('تسجيل الخروج'),
                content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('إلغاء'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('تسجيل الخروج'),
                  ),
                ],
              ),
            );

            if (shouldSignOut == true) {
              // Sign out using auth service
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.signOut();

              if (mounted) {
                Navigator.pop(context); // Close drawer
                // The AuthWrapper will automatically redirect to SignInScreen
              }
            }
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            children: const [
              Icon(
                Icons.logout,
                color: Colors.red,
                size: 24,
              ),
              SizedBox(width: 16),
              Text(
                'تسجيل الخروج',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}