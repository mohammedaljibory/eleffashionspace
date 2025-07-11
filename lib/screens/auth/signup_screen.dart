import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/location_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/phone_input_field.dart';
import 'location_picker_screen.dart';
import 'signin_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  double? _latitude;
  double? _longitude;
  String? _address;
  bool _isGettingLocation = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Get current location using GPS
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      final address = await LocationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _address = address;
        _isGettingLocation = false;
      });
    } else {
      setState(() {
        _isGettingLocation = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يمكن الحصول على الموقع. يرجى التحقق من الإعدادات'),
          ),
        );
      }
    }
  }

  // Choose location from map
  Future<void> _chooseFromMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLatitude: _latitude,
          initialLongitude: _longitude,
        ),
      ),
    );

    if (result != null && result is Map) {
      setState(() {
        _latitude = result['latitude'];
        _longitude = result['longitude'];
        _address = result['address'];
      });
    }
  }

  // Submit form
  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_latitude == null || _longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى تحديد موقعك'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final authService = Provider.of<AuthService>(context, listen: false);

      final result = await authService.signUp(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
        latitude: _latitude,
        longitude: _longitude,
        address: _address,
      );

      if (mounted) {
        if (result['success']) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF3E7DF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF513E35),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'الف',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Title
                const Text(
                  'إنشاء حساب جديد',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF513E35),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Name field
                CustomTextField(
                  label: 'الاسم الكامل',
                  hint: 'أدخل اسمك الكامل',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال الاسم';
                    }
                    if (value.length < 3) {
                      return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Phone field
                // Replace the phone CustomTextField with:
                PhoneInputField(
                  controller: _phoneController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال رقم الجوال';
                    }
                    // Remove spaces for validation
                    final phone = value.replaceAll(' ', '');
                  //  if (!phone.startsWith('05') || phone.length != 10) {
                  //    return 'يرجى إدخال رقم جوال صحيح';
                  //  }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Password field
                CustomTextField(
                  label: 'كلمة المرور',
                  hint: 'أدخل كلمة مرور قوية',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال كلمة المرور';
                    }
                    if (value.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Confirm password field
                CustomTextField(
                  label: 'تأكيد كلمة المرور',
                  hint: 'أعد إدخال كلمة المرور',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى تأكيد كلمة المرور';
                    }
                    if (value != _passwordController.text) {
                      return 'كلمات المرور غير متطابقة';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Location section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[300]!,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'موقع التوصيل',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF513E35),
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (_address != null) ...[
                        Text(
                          _address!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isGettingLocation ? null : _getCurrentLocation,
                              icon: _isGettingLocation
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Icon(Icons.my_location),
                              label: Text(_isGettingLocation ? 'جاري التحديد...' : 'موقعي الحالي'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF513E35),
                                side: const BorderSide(
                                  color: Color(0xFF513E35),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _chooseFromMap,
                              icon: const Icon(Icons.map),
                              label: const Text('اختر من الخريطة'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF513E35),
                                side: const BorderSide(
                                  color: Color(0xFF513E35),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Sign up button
                ElevatedButton(
                  onPressed: authService.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF513E35),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: authService.isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'إنشاء حساب',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لديك حساب بالفعل؟',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignInScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          color: Color(0xFF513E35),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}