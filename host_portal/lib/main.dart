import 'dart:async';
import 'dart:convert';
import 'dart:html' as html; // Flutter web only
import 'package:flutter/material.dart';

String proxyUrl(String url) {
  return url.startsWith('http')
      ? 'http://localhost:8080/proxy?url=${Uri.encodeComponent(url)}'
      : url;
}

void main() {
  runApp(const HostPortalApp());
}

class HostPortalApp extends StatelessWidget {
  const HostPortalApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tapovana Host Portal',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const HostHomePage(),
    );
  }
}

class HostHomePage extends StatefulWidget {
  const HostHomePage({super.key});
  @override
  State<HostHomePage> createState() => _HostHomePageState();
}

class _HostHomePageState extends State<HostHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _imageUrl = TextEditingController();
  final _rating = TextEditingController(text: '4.5');
  final _distance = TextEditingController(text: '1.0');
  bool _verified = true;
  final _price30 = TextEditingController(text: '99');
  final _price1h = TextEditingController(text: '149');
  final _price2h = TextEditingController(text: '249');
  final _price3h = TextEditingController(text: '329');
  final _price4h = TextEditingController(text: '389');
  final _starts = TextEditingController(text: '11:00, 11:30, 12:00');

  List<Map<String, dynamic>> _properties = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final resp = await html.HttpRequest.getString('http://localhost:8080/properties');
      _properties = (jsonDecode(resp) as List).cast<Map<String, dynamic>>();
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final id = 'h_${DateTime.now().millisecondsSinceEpoch}';
    final data = {
      'id': id,
      'name': _name.text.trim(),
      'imageAsset': _imageUrl.text.trim(),
      'rating': double.tryParse(_rating.text.trim()) ?? 4.0,
      'distanceKm': double.tryParse(_distance.text.trim()) ?? 1.0,
      'verified': _verified,
      'prices': {
        '30m': double.tryParse(_price30.text.trim()) ?? 0,
        '1h': double.tryParse(_price1h.text.trim()) ?? 0,
        '2h': double.tryParse(_price2h.text.trim()) ?? 0,
        '3h': double.tryParse(_price3h.text.trim()) ?? 0,
        '4h': double.tryParse(_price4h.text.trim()) ?? 0,
      },
      'nextStarts': _starts.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
    };
    try {
      await html.HttpRequest.request(
        'http://localhost:8080/properties',
        method: 'POST',
        sendData: jsonEncode(data),
        requestHeaders: {'Content-Type': 'application/json'},
      );
      _name.clear();
      _imageUrl.clear();
      _starts.text = '11:00, 11:30, 12:00';
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing published')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Host Portal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Create a new listing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      _field('Name', _name),
                      _field('Image URL', _imageUrl, hint: 'https://...'),
                      Row(children: [
                        Expanded(child: _field('Rating', _rating)),
                        const SizedBox(width: 12),
                        Expanded(child: _field('Distance (km)', _distance)),
                      ]),
                      SwitchListTile(
                        title: const Text('Verified'),
                        value: _verified,
                        onChanged: (v) => setState(() => _verified = v),
                        contentPadding: EdgeInsets.zero,
                      ),
                      Row(children: [
                        Expanded(child: _field('30m', _price30)),
                        const SizedBox(width: 8),
                        Expanded(child: _field('1h', _price1h)),
                        const SizedBox(width: 8),
                        Expanded(child: _field('2h', _price2h)),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: _field('3h', _price3h)),
                        const SizedBox(width: 8),
                        Expanded(child: _field('4h', _price4h)),
                      ]),
                      _field('Upcoming start times', _starts, hint: 'e.g. 11:00, 11:30'),
                      const SizedBox(height: 12),
                      FilledButton.icon(onPressed: _submit, icon: const Icon(Icons.publish), label: const Text('Publish')),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Your Listings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                IconButton(onPressed: _load, icon: const Icon(Icons.refresh))
              ],
            ),
            const SizedBox(height: 8),
            if (_loading) const LinearProgressIndicator(),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _properties.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final p = _properties[i];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(proxyUrl(p['imageAsset']), width: 56, height: 56, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 56, height: 56,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                  title: Text(p['name']),
                  subtitle: Text('Rating: ${p['rating']} • ${p['distanceKm']} km'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      try {
                        await html.HttpRequest.request(
                          'http://localhost:8080/properties/${p['id']}',
                          method: 'DELETE',
                        );
                        await _load();
                      } catch (_) {}
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(labelText: label, hintText: hint),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      ),
    );
  }
}
