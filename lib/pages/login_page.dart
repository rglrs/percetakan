import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk kDebugMode
import 'package:percetakan/core/app_styles.dart';
// import 'package:http/http.dart' as http; // Tidak lagi dibutuhkan di sini
// import 'dart:convert'; // Tidak lagi dibutuhkan di sini
// import 'package:shared_preferences/shared_preferences.dart'; // Tidak lagi dibutuhkan di sini

import 'package:percetakan/pages/main_screen.dart';
import 'package:percetakan/core/app_colors.dart';
// import 'package:percetakan/core/app_styles.dart'; // Jika AppStyles.button digunakan, pastikan importnya ada
import 'package:percetakan/pages/components/custom_text_field.dart';
import 'package:percetakan/controllers/auth_controller.dart'; // Import controller

class LoginPage extends StatefulWidget {
  // Nama class diubah menjadi LoginPage
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController =
      AuthController(); // Instansiasi controller

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  // Key untuk SharedPreferences dipindahkan ke AuthController
  // static const String _rememberedEmailKey = 'remembered_email';
  // static const String _rememberMeStatusKey = 'remember_me_status';
  // static const String _authTokenKey = 'auth_token';

  @override
  void initState() {
    super.initState();
    _loadRememberedUser();
  }

  Future<void> _loadRememberedUser() async {
    // Menggunakan method dari controller untuk memuat data
    final rememberedData = await _authController.getRememberedUser();
    if (mounted) {
      setState(() {
        _emailController.text = rememberedData['email'];
        _rememberMe = rememberedData['rememberMe'];
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  // _apiBaseUrl dipindahkan ke ApiConfig dan digunakan oleh AuthController
  // String get _apiBaseUrl { ... }

  Future<void> _handleLogin() async {
    if (kDebugMode) print('--- _handleLogin UI START ---');
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    // Panggil method login dari controller
    final result = await _authController.login(email, password, _rememberMe);

    setState(() {
      _isLoading = false;
    });
    if (kDebugMode) print('--- _handleLogin UI END ---');

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Login berhasil!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        _showErrorDialog(result['message'] ?? 'Login gagal.');
      }
    }
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(
            seconds: 4,
          ), // Durasi bisa lebih lama untuk error
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = Colors.grey.shade600;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    width: 320,
                    height: 240,
                    child: Image.network(
                      'https://storage.googleapis.com/a1aa/image/6c4da248-fabb-450d-2db2-c129c3d64ea7.jpg',
                      fit: BoxFit.contain,
                      semanticLabel:
                          'Illustration of a woman with dark skin and curly hair sitting on a dark gray armchair using a tablet, next to a large phone screen showing a login form, with a small cactus plant in a pot on the right',
                      loadingBuilder: (
                        BuildContext context,
                        Widget child,
                        ImageChunkEvent? loadingProgress,
                      ) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                          ),
                        );
                      },
                      errorBuilder: (
                        BuildContext context,
                        Object exception,
                        StackTrace? stackTrace,
                      ) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 100,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Masuk',
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Silakan Masuk untuk melanjutkan',
                  style: TextStyle(
                    color: AppColors.third,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Email',
                  controller: _emailController,
                  hintText: 'Masukkan email Anda',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(Icons.email_outlined, color: iconColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Masukkan format email yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Password',
                  controller: _passwordController,
                  hintText: 'Masukkan password Anda',
                  obscureText: _obscurePassword,
                  prefixIcon: Icon(Icons.lock_outline, color: iconColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: iconColor,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _rememberMe = value;
                            });
                          }
                        },
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _rememberMe = !_rememberMe;
                        });
                      },
                      child: Text(
                        'Remember me',
                        style: TextStyle(
                          color: AppColors.third,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          fontFamily:
                              'Inter', // Pastikan font 'Inter' ada di pubspec.yaml
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32), // Tambah jarak sebelum tombol
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _handleLogin, // Disable tombol saat loading
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // textStyle: AppStyles.heading2, // Periksa apakah AppStyles.heading2 cocok untuk tombol
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                            : Text(
                              'Masuk',
                              // Jika AppStyles.button tidak terdefinisi, gunakan TextStyle manual
                              style: AppStyles.buttonLogin,
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
