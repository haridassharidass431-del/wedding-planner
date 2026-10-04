import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/mock_wedding_repository.dart';
import '../main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  void _login() {
    final repo = MockWeddingRepository();
    if (!repo.login(email: _email.text, password: _password.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account not found. Register first, then sign in.'),
        ),
      );
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    AppConstants.logoAssetPath,
                    height: 150,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.favorite,
                      size: 72,
                      color: AppColors.primaryPlum,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Welcome back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryPlum,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue planning beautifully.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Gmail / Email',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _password,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text('Register / Create Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _email = TextEditingController(),
      _username = TextEditingController(),
      _password = TextEditingController(),
      _confirm = TextEditingController();
  String _role = 'Customer';
  @override
  void dispose() {
    for (final c in [_name, _email, _username, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create account')),
    body: SafeArea(
      child: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Join Haventra',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryPlum,
              ),
            ),
            const SizedBox(height: 20),
            _field(_name, 'Name'),
            _field(_email, 'Gmail / Email', type: TextInputType.emailAddress),
            _field(_username, 'Username'),
            _field(_password, 'Password', obscure: true),
            _field(_confirm, 'Confirm Password', obscure: true),
            const SizedBox(height: 8),
            const Text(
              'Select Role',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Customer',
                  label: Text('Customer'),
                  icon: Icon(Icons.favorite_outline),
                ),
                ButtonSegment(
                  value: 'Wedding Vendor',
                  label: Text('Vendor'),
                  icon: Icon(Icons.storefront_outlined),
                ),
              ],
              selected: {_role},
              onSelectionChanged: (s) => setState(() => _role = s.first),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (!_form.currentState!.validate()) {
                    return;
                  }
                  final ok = MockWeddingRepository().registerAccount(
                    name: _name.text,
                    email: _email.text,
                    username: _username.text,
                    password: _password.text,
                    role: _role,
                  );
                  if (!ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'An account with this email already exists.',
                        ),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account created. Please log in.'),
                    ),
                  );
                },
                child: const Text('Create Account'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  Widget _field(
    TextEditingController c,
    String label, {
    bool obscure = false,
    TextInputType? type,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: c,
      obscureText: obscure,
      keyboardType: type,
      decoration: InputDecoration(labelText: label),
      validator: (v) {
        if ((v ?? '').trim().isEmpty) {
          return 'Enter $label';
        }
        if (label.contains('Email') && !(v ?? '').contains('@')) {
          return 'Enter a valid email';
        }
        if (label == 'Password' && (v?.length ?? 0) < 6) {
          return 'Use at least 6 characters';
        }
        if (label == 'Confirm Password' && v != _password.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    ),
  );
}
