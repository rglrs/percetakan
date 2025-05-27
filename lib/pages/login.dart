import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFFF1F5F9);
    final Color darkTextColor = const Color(0xFF1E293B);
    final Color grayTextColor = const Color(0xFF475569);
    final Color inputBorderColor = Colors.grey.shade300;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Masuk',
                style: TextStyle(
                  color: darkTextColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Silakan Masuk untuk melanjutkan',
                style: TextStyle(
                  color: grayTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 24),
              // Email input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: inputBorderColor),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.email_outlined, color: Colors.grey.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8), // placeholder gray
                            fontSize: 14,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Password input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: inputBorderColor),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, color: Colors.grey.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Password',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    Icon(
                      Icons.visibility_outlined,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Remember me checkbox
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: false,
                      onChanged: (value) {},
                      activeColor: darkTextColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Remember me',
                    style: TextStyle(
                      color: darkTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Masuk button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkTextColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                  child: const Text('Masuk'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
