import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:teammates/main.dart';
import 'package:teammates/services/error_service.dart';
import 'package:teammates/widgets/custom_button_style.dart';

class RegisterModal extends StatefulWidget {
  const RegisterModal({Key? key}) : super(key: key);

  @override
  State<RegisterModal> createState() => _RegisterModalState();
}

class _RegisterModalState extends State<RegisterModal> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
              content: Text('Sprawdź email, aby potwierdzić rejestrację!')),
        );
        Navigator.of(context).pop(); // Close the modal
      }
    } on AuthException catch (error) {
      ErrorService.logError(
          errorMessage: error.message, operationType: 'signUp');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error.message),
              backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } catch (error) {
      ErrorService.logError(
          errorMessage: error.toString(), operationType: 'signUp-general');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text('Wystąpił nieoczekiwany błąd'),
              backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rejestracja'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę podać email';
                  }
                  if (!value.contains('@')) {
                    return 'Proszę podać poprawny adres email';
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
                  if (value.length < 6) {
                    return 'Hasło musi mieć co najmniej 6 znaków';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Potwierdź hasło'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę potwierdzić hasło';
                  }
                  if (value != _passwordController.text) {
                    return 'Hasła nie pasują do siebie';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the modal
          },
          child: const Text('Anuluj'),
        ),
        if (_isLoading)
          const CircularProgressIndicator()
        else
          ElevatedButton(
            onPressed: _signUp,
            style: getCustomButtonStyle(),
            child: const Text('Zarejestruj się'),
          ),
      ],
    );
  }
}
