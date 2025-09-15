import 'package:flutter/material.dart';
import 'package:teammates/widgets/custom_button_style.dart';

class EmailConfirmationSuccessScreen extends StatelessWidget {
  const EmailConfirmationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktywacja Konta'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 24),
              Text(
                'Twoje konto zostało pomyślnie aktywowane!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Możesz się teraz zalogować.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Navigate back to the auth gate/login screen
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                },
                style: getCustomButtonStyle(),
                child: const Text('Przejdź do logowania'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
