import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/panel_controller_provider.dart';
import '../widgets/led_preview.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _messageController;
  String? _selectedAnimation;

  static const animations = [
    'none',
    'scroll-left',
    'scroll-right',
    'blink',
    'slide-up',
  ];

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(text: 'Hello IoT World!');
    _selectedAnimation = animations.first;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PanelControllerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compose Message'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              provider.disconnect();
              Navigator.of(context).pop();
            },
            tooltip: 'Disconnect',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _messageController,
                maxLength: 120,
                decoration: const InputDecoration(
                  labelText: 'Message to display',
                  hintText: 'Type the text that should appear on the LED wall',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a message';
                  }
                  return null;
                },
                onChanged: (_) {
                  provider.clearError();
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedAnimation,
              decoration: const InputDecoration(
                labelText: 'Animation',
                border: OutlineInputBorder(),
              ),
              items: animations
                  .map((name) => DropdownMenuItem(
                        value: name,
                        child: Text(name.replaceAll('-', ' ').toUpperCase()),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAnimation = value;
                });
              },
            ),
            const SizedBox(height: 24),
            LedPreview(message: _messageController.text),
            const SizedBox(height: 16),
            if (provider.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  provider.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: provider.isBusy
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        await provider.sendMessage(
                          _messageController.text.trim(),
                          animation: _selectedAnimation == 'none' ? null : _selectedAnimation,
                        );
                        if (provider.error == null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Message sent successfully')),
                          );
                        }
                      },
                icon: provider.isBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: const Text('Send to Panel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
