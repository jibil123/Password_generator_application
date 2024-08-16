import 'package:flutter/material.dart';
import 'package:password_generate_application/password_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PasswordProvider(),
      child: MaterialApp(
        title: 'Password Manager',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: PasswordManagerScreen(),
      ),
    );
  }
}

// ignore: must_be_immutable
class PasswordManagerScreen extends StatelessWidget {
  final TextEditingController _lengthController = TextEditingController();
  PasswordManagerScreen({super.key});
  var indexes = 0;
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Manager'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: formKey,
              child: TextFormField(
                validator: (value) {
                  int? numberValue = int.tryParse(value!);
                  if (numberValue! < 8) {
                    return 'enter minimum 8';
                  } else {
                    return null;
                  }
                },
                controller: _lengthController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^(1[0-6]?|[1-9])$')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Password Length',
                  suffixText: 'Max limit 16',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            _CheckboxTile(
              label: 'Include Uppercase',
              value: context.watch<PasswordProvider>().includeUppercase,
              onChanged: (value) {
                context
                    .read<PasswordProvider>()
                    .setIncludeUppercase(value ?? true);
              },
            ),
            _CheckboxTile(
              label: 'Include Lowercase',
              value: context.watch<PasswordProvider>().includeLowercase,
              onChanged: (value) {
                context
                    .read<PasswordProvider>()
                    .setIncludeLowercase(value ?? true);
              },
            ),
            _CheckboxTile(
              label: 'Include Numbers',
              value: context.watch<PasswordProvider>().includeNumbers,
              onChanged: (value) {
                context
                    .read<PasswordProvider>()
                    .setIncludeNumbers(value ?? true);
              },
            ),
            _CheckboxTile(
              label: 'Include Special Characters',
              value: context.watch<PasswordProvider>().includeSpecial,
              onChanged: (value) {
                context
                    .read<PasswordProvider>()
                    .setIncludeSpecial(value ?? true);
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  int length = int.tryParse(_lengthController.text) ?? 8;
                  String password = context
                      .read<PasswordProvider>()
                      .generatePassword(
                        length,
                        includeUppercase:
                            context.read<PasswordProvider>().includeUppercase,
                        includeLowercase:
                            context.read<PasswordProvider>().includeLowercase,
                        includeNumbers:
                            context.read<PasswordProvider>().includeNumbers,
                        includeSpecial:
                            context.read<PasswordProvider>().includeSpecial,
                      );
                  context.read<PasswordProvider>().addPassword(password);
                }
              },
              child: const Text('Generate Password'),
            ),
            Expanded(
              child: Consumer<PasswordProvider>(
                builder: (context, passwordProvider, child) {
                  return ListView.builder(
                    itemCount: passwordProvider.passwords.length,
                    itemBuilder: (context, index) {
                      indexes = index + 1;
                      return ListTile(
                        leading: Text('$indexes'),
                        title: Text(passwordProvider.passwords[index]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                    text: passwordProvider.passwords[index]));
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Password copied to clipboard')));
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                context
                                    .read<PasswordProvider>()
                                    .deletePassword(index);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckboxTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CheckboxTile(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Text(label),
      ],
    );
  }
}
