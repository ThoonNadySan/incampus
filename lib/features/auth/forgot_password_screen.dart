import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:incampus/services/auth_service.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final String? initialEmail;

  const ForgotPasswordScreen({
    super.key,
    this.initialEmail,
  });

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late final TextEditingController _emailController;
  late final GlobalKey<FormState> _formKey;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _errorMessage = null;
      _successMessage = null;
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      await authService.sendPasswordResetEmail(_emailController.text.trim());

      if (mounted) {
        setState(() {
          _successMessage =
              'Password reset email sent to ${_emailController.text.trim()}. Please check your email and follow the link to reset your password.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _extractErrorMessage(e);
          _isLoading = false;
        });
      }
    }
  }

  String _extractErrorMessage(dynamic error) {
    final errorString = error.toString();

    // Handle different exception formats
    if (errorString.contains('Exception: ')) {
      return errorString.replaceAll('Exception: ', '');
    } else if (errorString.contains('FirebaseAuthException')) {
      return errorString;
    }

    // Return the original error message
    return errorString.isEmpty
        ? 'An unknown error occurred. Please try again.'
        : errorString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'Forgot your password?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'No worries! Enter your email address below and we\'ll send you a link to reset your password.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
              ),
              const SizedBox(height: 32),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_errorMessage != null) const SizedBox(height: 16),
              if (_successMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_successMessage != null) const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                enabled: _successMessage == null && !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: const Icon(Icons.email),
                  hintText: 'Enter your registered email',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_successMessage == null)
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSendResetEmail,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Send Reset Link',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              if (_successMessage != null)
                ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : () => context.pop(),
                  child: const Text('Back to Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
