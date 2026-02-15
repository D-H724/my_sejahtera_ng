import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:my_sejahtera_ng/core/providers/user_provider.dart';
import 'package:my_sejahtera_ng/core/theme/app_theme.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';
import 'package:my_sejahtera_ng/core/utils/ui_utils.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _emailController = TextEditingController();
  final _answerController = TextEditingController();
  final _newPasswordController = TextEditingController();
  
  // State
  int _step = 0; // 0: Email, 1: Security Question, 2: Reset Password
  bool _isLoading = false;
  String? _securityQuestion;

  Future<void> _handleEmailSubmit() async {
    if (_emailController.text.trim().isEmpty) {
      showElegantErrorDialog(context, title: "Input Required", message: "Please enter your email address.");
      return;
    }

    setState(() => _isLoading = true);
    
    // Simulate delay for smooth UI
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final question = await ref.read(userProvider.notifier).getSecurityQuestion(_emailController.text.trim());
      
      if (!mounted) return;
      
      if (question != null && question.isNotEmpty) {
        setState(() {
          _securityQuestion = question;
          _step = 1;
        });
      } else {
        showElegantErrorDialog(context, title: "User Not Found", message: "No account found with this email, or security question not set.");
      }
    } catch (e) {
      if (!mounted) return;
      showElegantErrorDialog(context, title: "Error", message: "Something went wrong. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAnswerSubmit() async {
    if (_answerController.text.trim().isEmpty) {
      showElegantErrorDialog(context, title: "Input Required", message: "Please enter your security answer.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isCorrect = await ref.read(userProvider.notifier).verifySecurityAnswer(
        _emailController.text.trim(),
        _answerController.text.trim(),
      );
      
      if (!mounted) return;
      
      if (isCorrect) {
        setState(() => _step = 2);
      } else {
        showElegantErrorDialog(context, title: "Incorrect Answer", message: "That answer is incorrect. Please try again.");
      }
    } catch (e) {
      if (!mounted) return;
      showElegantErrorDialog(context, title: "Error", message: "Verification failed. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResetSubmit() async {
    if (_newPasswordController.text.trim().length < 6) {
      showElegantErrorDialog(context, title: "Invalid Password", message: "Password must be at least 6 characters long.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(userProvider.notifier).resetPassword(
        _emailController.text.trim(),
        _newPasswordController.text.trim(),
      );
      
      if (!mounted) return;
      
      showElegantSuccessDialog(
        context, 
        title: "Password Reset!", 
        message: "Your password has been updated successfully. You can now login.",
        buttonText: "Back to Login",
        onPressed: () {
          Navigator.pop(context); // Close dialog
          Navigator.pop(context); // Back to Login
        }
      );
      
    } catch (e) {
      if (!mounted) return;
      showElegantErrorDialog(context, title: "Reset Failed", message: "Could not reset password. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Recover Account"),
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildCurrentStep(),
                ),
              ).animate().slideY(begin: 0.2, end: 0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return Column(
          key: const ValueKey(0),
          children: [
            const Icon(LucideIcons.lock, size: 48, color: Colors.white70),
            const SizedBox(height: 15),
            const Text("Forgot Password?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            const Text("Enter your email to find your account.", style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
            const SizedBox(height: 30),
            _buildTextField("Email Address", LucideIcons.mail, _emailController),
            const SizedBox(height: 30),
            _buildButton("Find Account", _handleEmailSubmit),
          ],
        );
      case 1:
        return Column(
          key: const ValueKey(1),
          children: [
            const Icon(LucideIcons.shieldQuestion, size: 48, color: Colors.white70),
            const SizedBox(height: 15),
            const Text("Security Check", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            Text("$_securityQuestion", style: const TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
            const SizedBox(height: 30),
            _buildTextField("Your Answer", LucideIcons.keyRound, _answerController),
            const SizedBox(height: 30),
            _buildButton("Verify Answer", _handleAnswerSubmit),
          ],
        );
      case 2:
        return Column(
          key: const ValueKey(2),
          children: [
            const Icon(LucideIcons.checkCircle, size: 48, color: AppTheme.accentTeal),
            const SizedBox(height: 15),
            const Text("Reset Password", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            const Text("Enter your new password below.", style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
            const SizedBox(height: 30),
            _buildTextField("New Password", LucideIcons.lock, _newPasswordController, isPassword: true),
            const SizedBox(height: 30),
            _buildButton("Reset Password", _handleResetSubmit),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
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

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentTeal,
          foregroundColor: AppTheme.primaryDark,
        ),
        child: _isLoading
            ? const CircularProgressIndicator()
            : Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
