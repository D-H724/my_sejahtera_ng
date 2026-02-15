import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:my_sejahtera_ng/core/providers/user_provider.dart';
import 'package:my_sejahtera_ng/core/theme/app_theme.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _icController = TextEditingController();
  final _phoneController = TextEditingController();
  final _securityAnswerController = TextEditingController();

  final String _securityQuestion = "What is your favorite pet's name?";
  bool _isLoading = false;

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await ref.read(userProvider.notifier).signUp(
              email: _usernameController.text.trim(),
              password: _passwordController.text.trim(),
              fullName: _nameController.text.trim(),
              username: _usernameController.text.trim().split('@')[0], // Extract username from email
              icNumber: _icController.text.trim(),
              phone: _phoneController.text.trim(),
            );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created! Please check your email to confirm."), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
        
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration Failed: ${e.toString().replaceAll('Exception:', '')}"), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Create Account"),
        leading: const BackButton(color: Colors.white),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryDark, AppTheme.primaryBlue],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: GlassContainer(
                child: Column(
                  children: [
                    _buildTextField("Full Name", LucideIcons.user, _nameController),
                    const SizedBox(height: 15),
                    _buildTextField("IC Number", LucideIcons.creditCard, _icController),
                    const SizedBox(height: 15),
                    _buildTextField("Phone Number", LucideIcons.phone, _phoneController),
                    const SizedBox(height: 15),
                    _buildTextField("Email", LucideIcons.mail, _usernameController),
                    const SizedBox(height: 15),
                    _buildTextField("Password", LucideIcons.lock, _passwordController, isPassword: true),
                    const SizedBox(height: 15),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 10),
                    Text("Security Question: $_securityQuestion", style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 10),
                    _buildTextField("Answer", LucideIcons.helpCircle, _securityAnswerController),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? _handleSignUp : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentTeal,
                          foregroundColor: AppTheme.primaryDark,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text("Register", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.2, end: 0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      validator: (value) => value!.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white30),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppTheme.accentTeal),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
