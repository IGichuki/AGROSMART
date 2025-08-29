import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String firstName = '';
  String lastName = '';
  String phone = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _controller;
  late List<Animation<Offset>> _fieldAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fieldAnimations = List.generate(6, (i) {
      return Tween<Offset>(begin: Offset(1.5, 0), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(i * 0.1, 0.7 + i * 0.1, curve: Curves.easeOut),
        ),
      );
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFa8e063), Color(0xFF56ab2f)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SlideTransition(
                        position: _fieldAnimations[0],
                        child: _buildField(
                          label: 'First Name',
                          icon: Icons.person,
                          onSaved: (v) => firstName = v ?? '',
                          validator: (v) => v == null || v.isEmpty
                              ? 'Enter first name'
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SlideTransition(
                        position: _fieldAnimations[1],
                        child: _buildField(
                          label: 'Last Name',
                          icon: Icons.person_outline,
                          onSaved: (v) => lastName = v ?? '',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Enter last name' : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SlideTransition(
                        position: _fieldAnimations[2],
                        child: _buildField(
                          label: 'Phone Number',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          onSaved: (v) => phone = v ?? '',
                          validator: (v) => v == null || v.isEmpty
                              ? 'Enter phone number'
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SlideTransition(
                        position: _fieldAnimations[3],
                        child: _buildField(
                          label: 'Email',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (v) => email = v ?? '',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Enter email' : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SlideTransition(
                        position: _fieldAnimations[4],
                        child: _buildField(
                          label: 'Password',
                          icon: Icons.lock,
                          controller: _passwordController,
                          obscureText: true,
                          onSaved: (v) => password = v ?? '',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Enter password' : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SlideTransition(
                        position: _fieldAnimations[5],
                        child: _buildField(
                          label: 'Confirm Password',
                          icon: Icons.lock_outline,
                          controller: _confirmPasswordController,
                          obscureText: true,
                          onSaved: (v) => confirmPassword = v ?? '',
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Confirm your password';
                            }
                            if (v != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              _formKey.currentState?.save();
                              // TODO: Implement signup logic
                            }
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Already have an account? Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required IconData icon,
    TextEditingController? controller,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[700]),
        filled: true,
        fillColor: Colors.green[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }
}
