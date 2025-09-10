import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Added for kIsWeb

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:teammates/main.dart';
import 'package:teammates/services/error_service.dart';
import 'package:teammates/widgets/custom_button_style.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (response.user != null && mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    } on AuthException catch (error) {
      ErrorService.logError(
        errorMessage: error.message,
        operationType: 'signIn',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (error) {
      ErrorService.logError(
        errorMessage: error.toString(),
        operationType: 'signIn-general',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Wystąpił nieoczekiwany błąd'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sprawdź email, aby potwierdzić rejestrację!'),
          ),
        );
      }
    } on AuthException catch (error) {
      ErrorService.logError(
        errorMessage: error.message,
        operationType: 'signUp',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (error) {
      ErrorService.logError(
        errorMessage: error.toString(),
        operationType: 'signUp-general',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Wystąpił nieoczekiwany błąd'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _googleSignIn() async {
    try {
      await supabase.auth.signInWithOAuth(OAuthProvider.google);
    } on AuthException catch (error) {
      ErrorService.logError(
        errorMessage: error.message,
        operationType: 'googleSignIn',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (error) {
      ErrorService.logError(
        errorMessage: error.toString(),
        operationType: 'googleSignIn-general',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Wystąpił nieoczekiwany błąd'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _facebookSignIn() async {
    try {
      await supabase.auth.signInWithOAuth(OAuthProvider.facebook);
    } on AuthException catch (error) {
      ErrorService.logError(
        errorMessage: error.message,
        operationType: 'facebookSignIn',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (error) {
      ErrorService.logError(
        errorMessage: error.toString(),
        operationType: 'facebookSignIn-general',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Wystąpił nieoczekiwany błąd'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _appleSignIn() async {
    try {
      await supabase.auth.signInWithOAuth(OAuthProvider.apple);
    } on AuthException catch (error) {
      ErrorService.logError(
        errorMessage: error.message,
        operationType: 'appleSignIn',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (error) {
      ErrorService.logError(
        errorMessage: error.toString(),
        operationType: 'appleSignIn-general',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Wystąpił nieoczekiwany błąd'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logowanie')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę podać email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Hasło'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę podać hasło';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: _signIn,
                        style: getCustomButtonStyle(),
                        child: const Text('Zaloguj się'),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _googleSignIn,
                        style: getCustomButtonStyle(),
                        icon: const Icon(Icons.g_mobiledata), // Placeholder
                        label: const Text('Zaloguj się z Google'),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _facebookSignIn,
                        style: getCustomButtonStyle(),
                        icon: const Icon(Icons.facebook),
                        label: const Text('Zaloguj się z Facebook'),
                      ),
                      if (!kIsWeb && (Platform.isIOS || Platform.isMacOS))
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: ElevatedButton.icon(
                            onPressed: _appleSignIn,
                            style: getCustomButtonStyle(),
                            icon: const Icon(Icons.apple),
                            label: const Text('Zaloguj się z Apple'),
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 24),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: _signUp,
                  child: const Text('Nie masz konta? Zarejestruj się'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
