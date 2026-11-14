// Sign-in and account creation. Done once, before the mission, while online.
 
import 'package:flutter/material.dart';
 
import '../app/app_state.dart';
import '../data/remote_api.dart';
import 'theme.dart';
 
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
 
  @override
  State<LoginPage> createState() => _LoginPageState();
}
 
class _LoginPageState extends State<LoginPage> {
  static bool _createMode = false;
  final _name = TextEditingController();
  final _role = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _hidden = true;
  String? _error;
 
  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
 
  String _message(String code) {
    final key = 'err.$code';
    final text = t(key);
    return text == key ? t('err.generic', [code]) : text;
  }
  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    final name = _name.text.trim();
    final role = _role.text.trim();
    if (email.isEmpty || password.isEmpty || (_createMode && (name.isEmpty || role.isEmpty))) {
      setState(() => _error = t('login.required'));
      return;
    }
    if (password.length < 6) {
      setState(() => _error = t('login.pwshort'));
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_createMode) {
        await appState.signUp(name, role, email, password);
      } else {
        await appState.signIn(email, password);
      }
      // On success the app switches to the home screen by itself.
    } on RemoteException catch (e) {
      if (mounted) setState(() => _error = _message(e.code));
    } catch (_) {
      if (mounted) setState(() => _error = _message('UNKNOWN'));
    }
    if (mounted) setState(() => _busy = false);
  }
 
  InputDecoration _field(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    border: const OutlineInputBorder(),
  );
 
  @override

  Widget build(BuildContext context) {
    // Listening here makes the page follow a language change immediately.
    return AnimatedBuilder(animation: appState, builder: (context, _) => _content(context));
  }
 
  Widget _content(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment<String>(value: 'en', label: Text('EN')),
                        ButtonSegment<String>(value: 'fr', label: Text('FR')),
                      ],
                      selected: {appState.lang},
                      onSelectionChanged: (s) => appState.setLanguage(s.first),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Icon(Icons.health_and_safety, size: 64, color: scheme.primary),
                  const SizedBox(height: 8),
                  Text(
                    'AstroCare',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: isDark(context) ? kLightBlue : kNasaBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _createMode ? t('login.up') : t('login.in'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  if (_createMode) ...[
                    TextField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: _field(t('login.name'), Icons.person_outline),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _role,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      decoration: _field(t('login.role'), Icons.badge_outlined),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    decoration: _field(t('login.email'), Icons.mail_outline),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: _hidden,
                    onSubmitted: (_) => _busy ? null : _submit(),
                    decoration: _field(t('login.password'), Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_hidden ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _hidden = !_hidden),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline, size: 20, color: scheme.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_error!, style: TextStyle(color: scheme.error)),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          : Text(
                              _createMode ? t('login.submit.up') : t('login.submit.in'),
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                            _createMode = !_createMode;
                            _error = null;
                          }),
                    child: Text(_createMode ? t('login.in') : t('login.up')),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.primary.withAlpha(22),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.wifi_off, size: 20, color: scheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(t('login.info'), style: const TextStyle(height: 1.35)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
