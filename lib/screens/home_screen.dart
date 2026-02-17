import 'package:flutter/material.dart';
import 'package:boccia_coaching_app/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  final AuthService? authService;
  const HomeScreen({super.key, this.authService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boccia Coaching'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService?.signOut();
              // Avoid using the BuildContext across the async gap if the
              // widget was removed from the tree while signing out.
              if (!context.mounted) return;
              Navigator.of(context).pushReplacementNamed('/');
            },
          )
        ],
      ),
      body: const Center(
        child: Text(
          'Bienvenido a Boccia Coaching',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
