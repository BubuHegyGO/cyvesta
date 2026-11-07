import 'package:flutter/material.dart';
import '../services/auth_state.dart';

const Color _dialogBg = Color(0xFF072A40);
const Color _dialogBorder = Color(0xFF99FF99);
const Color _dialogAccent = Color(0xFFFF9F1C);
const Color _dialogTextDark = Color(0xFF0F172A);

AlertDialog _styledDialog({
  required String title,
  required Widget content,
  required List<Widget> actions,
}) {
  return AlertDialog(
    backgroundColor: _dialogBg,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: _dialogBorder, width: 1.4),
    ),
    title: Text(
      title,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    content: content,
    actions: actions,
  );
}

ButtonStyle get _primaryStyle => ElevatedButton.styleFrom(
      backgroundColor: _dialogAccent,
      foregroundColor: _dialogTextDark,
    );

// -----------------------------------------------------------------------------
// Elfelejtett jelszó
// -----------------------------------------------------------------------------

Future<void> showForgotPasswordDialog(BuildContext context, {String initialEmail = ''}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ForgotPasswordDialog(initialEmail: initialEmail),
  );
}

class _ForgotPasswordDialog extends StatefulWidget {
  final String initialEmail;
  const _ForgotPasswordDialog({required this.initialEmail});

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  late final TextEditingController _emailController;
  bool _busy = false;
  bool _sent = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });

    final result = await AuthState.sendPasswordReset(_emailController.text);
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result.success) {
        _sent = true;
      } else {
        _error = result.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      return _styledDialog(
        title: 'Levél elküldve ✅',
        content: const Text(
          'Ha ezzel az e-mail címmel létezik fiók, elküldtük a jelszó-visszaállító levelet. '
          'Nézd meg a levélszemét (spam) mappát is.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          ElevatedButton(
            style: _primaryStyle,
            onPressed: () => Navigator.pop(context),
            child: const Text('Rendben', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      );
    }

    return _styledDialog(
      title: 'Elfelejtett jelszó',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add meg az e-mail címed, és küldünk egy linket az új jelszó beállításához.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'E-mail cím',
              hintStyle: TextStyle(color: Colors.white38),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white38),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: _dialogBorder),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Mégse', style: TextStyle(color: Colors.white60)),
        ),
        ElevatedButton(
          style: _primaryStyle,
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Küldés', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// E-mail megerősítés (hirdetésfeladás előtt)
// -----------------------------------------------------------------------------

/// Igazat ad vissza, ha a felhasználó e-mail címe rendben van (megerősített, vagy nem jelszavas fiók).
/// Ha még nincs megerősítve, párbeszédablakot mutat az újraküldés és az ellenőrzés lehetőségével.
Future<bool> ensureEmailVerified(BuildContext context) async {
  if (!AuthState.needsEmailVerification) return true;

  // Lehet, hogy a felhasználó közben már megerősítette a címét.
  if (await AuthState.refreshAndCheckVerified()) return true;

  if (!context.mounted) return false;
  final verified = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _VerifyEmailDialog(),
  );
  return verified ?? false;
}

class _VerifyEmailDialog extends StatefulWidget {
  const _VerifyEmailDialog();

  @override
  State<_VerifyEmailDialog> createState() => _VerifyEmailDialogState();
}

class _VerifyEmailDialogState extends State<_VerifyEmailDialog> {
  bool _busy = false;
  String? _info;
  bool _infoIsError = false;

  Future<void> _resend() async {
    setState(() {
      _busy = true;
      _info = null;
    });
    final result = await AuthState.sendVerificationEmail();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _infoIsError = !result.success;
      _info = result.success
          ? 'Elküldtük az új visszaigazoló e-mailt. Nézd meg a levélszemét mappát is.'
          : result.message;
    });
  }

  Future<void> _check() async {
    setState(() {
      _busy = true;
      _info = null;
    });
    final ok = await AuthState.refreshAndCheckVerified();
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      _busy = false;
      _infoIsError = true;
      _info = 'Még nem látjuk a megerősítést. Kattints az e-mailben kapott linkre, majd próbáld újra.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final email = AuthState.userEmail.value;
    return _styledDialog(
      title: 'E-mail cím megerősítése',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hirdetés feladásához meg kell erősítened az e-mail címedet'
            '${email.isNotEmpty ? ' ($email)' : ''}. '
            'Kattints a regisztrációkor kapott levélben lévő linkre.',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          if (_info != null) ...[
            const SizedBox(height: 10),
            Text(
              _info!,
              style: TextStyle(
                color: _infoIsError ? Colors.redAccent : _dialogBorder,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: const Text('Bezárás', style: TextStyle(color: Colors.white60)),
        ),
        TextButton(
          onPressed: _busy ? null : _resend,
          child: const Text('Újraküldés', style: TextStyle(color: _dialogBorder)),
        ),
        ElevatedButton(
          style: _primaryStyle,
          onPressed: _busy ? null : _check,
          child: const Text('Megerősítettem', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Regisztráció után: "Küldtünk visszaigazoló e-mailt"
// -----------------------------------------------------------------------------

Future<void> showVerificationSentDialog(
  BuildContext context, {
  required String email,
  bool sent = true,
  String? extraMessage,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _VerificationSentDialog(email: email, sent: sent, extraMessage: extraMessage),
  );
}

class _VerificationSentDialog extends StatefulWidget {
  final String email;
  final bool sent;
  final String? extraMessage;

  const _VerificationSentDialog({required this.email, required this.sent, this.extraMessage});

  @override
  State<_VerificationSentDialog> createState() => _VerificationSentDialogState();
}

class _VerificationSentDialogState extends State<_VerificationSentDialog> {
  bool _resending = false;
  late bool _sent = widget.sent;
  String? _note;

  Future<void> _resend() async {
    setState(() {
      _resending = true;
      _note = null;
    });
    final r = await AuthState.sendVerificationEmail();
    if (!mounted) return;
    setState(() {
      _resending = false;
      if (r.success) _sent = true;
      _note = r.success ? 'Újra elküldtük a levelet.' : (r.message ?? 'Az újraküldés nem sikerült, próbáld később.');
    });
  }

  @override
  Widget build(BuildContext context) {
    return _styledDialog(
      title: 'Sikeres regisztráció! 🎉',
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _sent
                  ? 'Küldtünk egy visszaigazoló e-mailt ide:'
                  : 'A fiók létrejött, de a visszaigazoló e-mail küldése nem sikerült. Az újraküldés gombbal próbáld újra.',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            if (_sent) ...[
              const SizedBox(height: 6),
              Text(widget.email, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 10),
              const Text(
                'Kattints a levélben lévő linkre a fiókod megerősítéséhez. Ha nem találod, nézd meg a Spam / Levélszemét mappát is.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
            if (widget.extraMessage != null) ...[
              const SizedBox(height: 10),
              Text(widget.extraMessage!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
            if (_note != null) ...[
              const SizedBox(height: 10),
              Text(_note!, style: const TextStyle(color: _dialogBorder, fontSize: 12.5)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _resending ? null : _resend,
          child: _resending
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Újraküldés'),
        ),
        ElevatedButton(
          style: _primaryStyle,
          onPressed: () => Navigator.pop(context),
          child: const Text('Rendben', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
