import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/app_scaffold.dart';

class HomeScreen extends StatelessWidget {
  final AuthService? authService;
  const HomeScreen({super.key, this.authService});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      maxContentWidth: AppContentWidth.medium,
      appBar: AppBar(
        title: const Text('Boccia Coaching'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await (authService ?? AuthService.instance)
                  .logout(navigate: false);
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
