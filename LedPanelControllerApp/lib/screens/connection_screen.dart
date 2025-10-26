import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/panel_controller_provider.dart';
import 'message_screen.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _baseUrlController;
  late final TextEditingController _apiKeyController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<PanelControllerProvider>();
    _baseUrlController = TextEditingController(text: provider.baseUrl);
    _apiKeyController = TextEditingController(text: provider.apiKey);
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PanelControllerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to Signage'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the ESP32 device URL. The app will send HTTP requests to this endpoint.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _baseUrlController,
                decoration: const InputDecoration(
                  labelText: 'Device URL',
                  hintText: 'https://signage-controller.local',
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the controller URL';
                  }
                  if (!value.startsWith('http')) {
                    return 'Include the protocol (http or https)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API Key (optional)',
                  hintText: 'Paste issued API key',
                  prefixIcon: Icon(Icons.vpn_key),
                ),
                obscureText: true,
              ),
              const Spacer(),
              if (provider.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    provider.error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: provider.isBusy
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          provider
                            ..baseUrl = _baseUrlController.text.trim()
                            ..apiKey = _apiKeyController.text.trim();
                          await provider.connect();
                          if (provider.isConnected && context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const MessageScreen(),
                              ),
                            );
                          }
                        },
                  icon: provider.isBusy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi),
                  label: const Text('Connect'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
