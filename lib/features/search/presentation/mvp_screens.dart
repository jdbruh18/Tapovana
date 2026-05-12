import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/errors/api_error.dart';
import '../../../core/config/api_config.dart';

class AppColors {
  static const sage = Color(0xFF6B8E23);
  static const sky = Color(0xFF6FAFE7);
  static const cream = Color(0xFFF9F7F1);
  static const charcoal = Color(0xFF2E2E2E);
  static const error = Color(0xFFE76F51);
}

// ---------------- Splash ----------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadProperties();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const GateScreen()),
        );
      }
    });
  }

  Future<void> _loadProperties() async {
    try {
      final data = await _apiClient.getJsonList('/properties');
      remoteProperties = data
          .map((e) => Property.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      if (mounted) {
        setState(() => _hasError = true);
      }
    } catch (error) {
      debugPrint('Unexpected property load error: $error');
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.cream, Color(0xFFEFF4E6)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.terrain, size: 80, color: AppColors.sage),
              const SizedBox(height: 16),
              const Text('Tapovana', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('A Sacred Pause Between Journeys'),
              if (_hasError)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Unable to refresh stays. Showing cached mock data.',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- Auth Gate (mock) ----------------
class GateScreen extends StatelessWidget {
  const GateScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            const Text('Continue to Tapovana', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const RootShell()),
              ),
              child: const Text('Continue with Phone (Mock OTP)'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const RootShell()),
              ),
              child: const Text('Continue with Email'),
            ),
            const SizedBox(height: 24),
            const Text('Language: EN | HI', textAlign: TextAlign.center),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ---------------- Root Shell with bottom nav ----------------
class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  final _pages = const [HomeSearchScreen(), TripsScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event), label: 'Trips'),
          NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ---------------- Home / Search ----------------
class HomeSearchScreen extends StatefulWidget {
  const HomeSearchScreen({super.key});
  @override
  State<HomeSearchScreen> createState() => _HomeSearchScreenState();
}

class _HomeSearchScreenState extends State<HomeSearchScreen> {
  String city = 'Manali';
  DateTime date = DateTime.now();
  String startWindow = '06:00–18:00';
  String duration = '2h';
  int guests = 1;
  bool filterVerified = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Your Tapovana'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.help_outline)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(children: [
                    const Icon(Icons.place_outlined),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: city,
                        items: const [
                          DropdownMenuItem(value: 'Manali', child: Text('Manali')),
                          DropdownMenuItem(value: 'Kasol', child: Text('Kasol')),
                          DropdownMenuItem(value: 'Jibhi', child: Text('Jibhi')),
                          DropdownMenuItem(value: 'Bir', child: Text('Bir')),
                        ],
                        onChanged: (v) => setState(() => city = v ?? city),
                        decoration: const InputDecoration(labelText: 'City/District'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Icon(Icons.calendar_today_outlined),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Date',
                          hintText: '${date.year}-${date.month}-${date.day}',
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 60)),
                          );
                          if (picked != null) setState(() => date = picked);
                        },
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: startWindow,
                        items: const [
                          DropdownMenuItem(value: '05:00–21:00', child: Text('05:00–21:00')),
                          DropdownMenuItem(value: '06:00–18:00', child: Text('06:00–18:00')),
                          DropdownMenuItem(value: '08:00–20:00', child: Text('08:00–20:00')),
                        ],
                        onChanged: (v) => setState(() => startWindow = v ?? startWindow),
                        decoration: const InputDecoration(labelText: 'Start Window'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Icon(Icons.timer_outlined),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: duration,
                        items: const [
                          DropdownMenuItem(value: '30m', child: Text('30 min')),
                          DropdownMenuItem(value: '1h', child: Text('1 hour')),
                          DropdownMenuItem(value: '2h', child: Text('2 hours')),
                          DropdownMenuItem(value: '3h', child: Text('3 hours')),
                          DropdownMenuItem(value: '4h', child: Text('4 hours')),
                        ],
                        onChanged: (v) => setState(() => duration = v ?? duration),
                        decoration: const InputDecoration(labelText: 'Duration'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Icon(Icons.people_alt_outlined),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: guests,
                        items: List.generate(4, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                        onChanged: (v) => setState(() => guests = v ?? guests),
                        decoration: const InputDecoration(labelText: 'Guests'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    value: filterVerified,
                    title: const Text('Show Verified Homestays only'),
                    onChanged: (v) => setState(() => filterVerified = v),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResultsScreen(
                              query: SearchQuery(city: city, date: date, duration: duration, guests: guests, startWindow: startWindow, verifiedOnly: filterVerified),
                            ),
                          ),
                        );
                      },
                      child: const Text('Search Tapovana Stays'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Featured', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: (remoteProperties.isNotEmpty ? remoteProperties : mockProperties).length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (ctx, i) {
                final source = remoteProperties.isNotEmpty ? remoteProperties : mockProperties;
                return FeaturedCard(property: source[i]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FeaturedCard extends StatelessWidget {
  final Property property;
  const FeaturedCard({super.key, required this.property});
  @override
  Widget build(BuildContext context) {
    final imageUrl = property.imageAsset.startsWith('http')
        ? '${ApiConfig.baseUrl}/proxy?url=${Uri.encodeComponent(property.imageAsset)}'
        : property.imageAsset;
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ListingScreen(property: property, defaultDuration: '2h')),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.15), BlendMode.darken),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 12,
                bottom: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(property.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${property.distanceKm.toStringAsFixed(1)} km • ★ ${property.rating}', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.sage, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Verified', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- Results ----------------
class ResultsScreen extends StatelessWidget {
  final SearchQuery query;
  const ResultsScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    final source = remoteProperties.isNotEmpty ? remoteProperties : mockProperties;
    final results = source
        .where((p) => !query.verifiedOnly || p.verified)
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text('${query.city} • ${query.duration}')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) => ResultCard(property: results[i], duration: query.duration),
      ),
    );
  }
}

class ResultCard extends StatelessWidget {
  final Property property;
  final String duration;
  const ResultCard({super.key, required this.property, required this.duration});
  @override
  Widget build(BuildContext context) {
    final imageUrl = property.imageAsset.startsWith('http')
        ? '${ApiConfig.baseUrl}/proxy?url=${Uri.encodeComponent(property.imageAsset)}'
        : property.imageAsset;
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ListingScreen(property: property, defaultDuration: duration)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(imageUrl, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(property.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                      if (property.verified) ...[
                        const Icon(Icons.verified, color: AppColors.sage, size: 16),
                        const SizedBox(width: 4),
                      ],
                      Text('★ ${property.rating}')
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${property.distanceKm.toStringAsFixed(1)} km • Wi‑Fi • Hot Water • Heater'),
                  const SizedBox(height: 8),
                  Row(
                    children: property.nextStarts.take(3).map((t) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(label: Text(t)),
                    )).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text('₹${property.priceFor(duration).toStringAsFixed(0)} total ($duration)'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ---------------- Listing ----------------
class ListingScreen extends StatefulWidget {
  final Property property;
  final String defaultDuration;
  const ListingScreen({super.key, required this.property, required this.defaultDuration});
  @override
  State<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {
  String duration = '2h';
  String? startTime;

  @override
  void initState() {
    super.initState();
    duration = widget.defaultDuration;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.property.imageAsset.startsWith('http')
        ? '${ApiConfig.baseUrl}/proxy?url=${Uri.encodeComponent(widget.property.imageAsset)}'
        : widget.property.imageAsset;
    final slots = widget.property.generateSlots();
    return Scaffold(
      appBar: AppBar(title: Text(widget.property.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(imageUrl, height: 200, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.verified, color: AppColors.sage, size: 18),
            const SizedBox(width: 6),
            const Text('Verified • Local ID OK • Strict cancel'),
          ]),
          const SizedBox(height: 8),
          const Text('Amenities: Wi‑Fi · Hot Water · Heater'),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: ['30m', '1h', '2h', '3h', '4h']
              .map((d) => ChoiceChip(
                    label: Text(d),
                    selected: duration == d,
                    onSelected: (_) => setState(() => duration = d),
                  ))
              .toList()),
          const SizedBox(height: 12),
          const Text('Select Start Time'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: slots.map((t) => ChoiceChip(
                  label: Text(t),
                  selected: startTime == t,
                  onSelected: (_) => setState(() => startTime = t),
                )).toList(),
          ),
          const SizedBox(height: 16),
          PriceBar(
            price: widget.property.priceFor(duration),
            enabled: startTime != null,
            onPressed: startTime == null
                ? null
                : () => _openSlotHold(context, startTime!, duration, widget.property),
          ),
        ],
      ),
    );
  }

  void _openSlotHold(BuildContext context, String start, String duration, Property p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SlotHoldSheet(property: p, start: start, duration: duration),
    );
  }
}

class PriceBar extends StatelessWidget {
  final double price;
  final bool enabled;
  final VoidCallback? onPressed;
  const PriceBar({super.key, required this.price, required this.enabled, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Price'),
              Text('₹${price.toStringAsFixed(0)} total', style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
          ),
          ElevatedButton(
            onPressed: enabled ? onPressed : null,
            child: const Text('Book Tapovana'),
          ),
        ],
      ),
    );
  }
}

// ---------------- Slot Hold Sheet ----------------
class SlotHoldSheet extends StatefulWidget {
  final Property property;
  final String start;
  final String duration;
  const SlotHoldSheet({super.key, required this.property, required this.start, required this.duration});
  @override
  State<SlotHoldSheet> createState() => _SlotHoldSheetState();
}

class _SlotHoldSheetState extends State<SlotHoldSheet> {
  late Timer _timer;
  int secondsLeft = 300;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft <= 0) {
        t.cancel();
        return;
      }
      setState(() => secondsLeft = secondsLeft - 1);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.property.priceFor(widget.duration);
    final end = _computeEnd(widget.start, widget.duration);
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 12),
          Text('${widget.property.name}', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text('Slot: ${widget.start} – $end  •  Buffer: +15m'),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.timer, size: 18, color: AppColors.sage),
            const SizedBox(width: 6),
            Text('Held for ${_mmss(secondsLeft)}'),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: secondsLeft == 0 ? null : () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CheckoutScreen(property: widget.property, start: widget.start, end: end, duration: widget.duration, price: price)),
                );
              },
              child: Text('Pay ₹${price.toStringAsFixed(0)} & Hold'),
            ),
          ),
        ],
      ),
    );
  }

  static String _mmss(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  static String _computeEnd(String start, String duration) {
    final parts = start.split(':');
    var h = int.parse(parts[0]);
    var m = int.parse(parts[1]);
    int addMin = 0;
    switch (duration) {
      case '30m':
        addMin = 30;
        break;
      case '1h':
        addMin = 60;
        break;
      case '2h':
        addMin = 120;
        break;
      case '3h':
        addMin = 180;
        break;
      case '4h':
        addMin = 240;
        break;
      default:
        addMin = 0;
    }
    m += addMin;
    while (m >= 60) {
      h += 1;
      m -= 60;
    }
    h = h % 24;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}

// ---------------- Checkout ----------------
class CheckoutScreen extends StatelessWidget {
  final Property property;
  final String start;
  final String end;
  final String duration;
  final double price;
  const CheckoutScreen({super.key, required this.property, required this.start, required this.end, required this.duration, required this.price});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(property.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('Time: $start – $end  ($duration)'),
                  const SizedBox(height: 8),
                  Text('Price ₹${price.toStringAsFixed(0)}  + Taxes ₹0 = ₹${price.toStringAsFixed(0)}'),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Show a government ID at check‑in. Keep voucher offline.'),
            ),
            const SizedBox(height: 12),
            const Text('Pay with'),
            const SizedBox(height: 8),
            ToggleButtons(
              isSelected: const [true, false],
              onPressed: (_) {},
              children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('UPI')), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Card'))],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => SuccessScreen(property: property, start: start, end: end, duration: duration, price: price)),
              ),
              child: const Text('Pay & Book Tapovana (Mock)'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Success / Voucher ----------------
class SuccessScreen extends StatelessWidget {
  final Property property;
  final String start;
  final String end;
  final String duration;
  final double price;
  const SuccessScreen({super.key, required this.property, required this.start, required this.end, required this.duration, required this.price});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Confirmed')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Icon(Icons.check_circle, color: AppColors.sage, size: 72),
          const SizedBox(height: 8),
          Center(child: Text(property.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18))),
          Center(child: Text('Today $start – $end  ($duration)')),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            child: ListTile(
              title: const Text('Voucher'),
              subtitle: Text('G0-${DateTime.now().millisecondsSinceEpoch % 99999}'),
              trailing: ElevatedButton(onPressed: () {}, child: const Text('Download')),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('View on Map'))),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton(onPressed: () {}, child: const Text('WhatsApp Host'))),
          ]),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const RootShell()), (r) => false), child: const Text('Done')),
        ]),
      ),
    );
  }
}

// ---------------- Trips ----------------
class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Trips')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TripCard(title: 'Thachi Homestay', time: '12:00 – 14:00 (2h)', status: 'Upcoming'),
          const SizedBox(height: 12),
          TripCard(title: 'Jibhi Village Room', time: '10:30 – 11:00 (30m)', status: 'Past'),
        ],
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  final String title; final String time; final String status;
  const TripCard({super.key, required this.title, required this.time, required this.status});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: ListTile(
        title: Text(title),
        subtitle: Text(time),
        trailing: Text(status, style: const TextStyle(color: AppColors.sage)),
      ),
    );
  }
}

// ---------------- Profile ----------------
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(radius: 28, child: Icon(Icons.person)),
          const SizedBox(height: 8),
          const Center(child: Text('Traveler Name')),
          const Center(child: Text('EN | HI')),
          const SizedBox(height: 16),
          const ListTile(leading: Icon(Icons.badge_outlined), title: Text('Upload ID (optional pre‑capture)')),
          const ListTile(leading: Icon(Icons.payment_outlined), title: Text('Saved Payments')),
          const ListTile(leading: Icon(Icons.chat_outlined), title: Text('Support (WhatsApp)')),
          const ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
        ],
      ),
    );
  }
}

// ---------------- Mock models/data ----------------
class SearchQuery {
  final String city; final DateTime date; final String duration; final int guests; final String startWindow; final bool verifiedOnly;
  SearchQuery({required this.city, required this.date, required this.duration, required this.guests, required this.startWindow, required this.verifiedOnly});
}

class Property {
  final String id;
  final String name;
  final String imageAsset;
  final double rating;
  final double distanceKm;
  final bool verified;
  final Map<String, double> prices;
  final List<String> nextStarts;

  const Property({required this.id, required this.name, required this.imageAsset, required this.rating, required this.distanceKm, required this.verified, required this.prices, required this.nextStarts});

  factory Property.fromJson(Map<String, dynamic> j) => Property(
        id: (j['id'] as String?) ?? (j['name'] as String?) ?? 'unknown',
        name: (j['name'] as String?) ?? 'Unnamed Property',
        imageAsset: (j['imageAsset'] as String?) ?? '',
        rating: (j['rating'] as num?)?.toDouble() ?? 0.0,
        distanceKm: (j['distanceKm'] as num?)?.toDouble() ?? 0.0,
        verified: (j['verified'] as bool?) ?? false,
        prices: (j['prices'] as Map?)?.map((k, v) => MapEntry(k.toString(), (v as num?)?.toDouble() ?? 0.0)) ?? {},
        nextStarts: (j['nextStarts'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageAsset': imageAsset,
        'rating': rating,
        'distanceKm': distanceKm,
        'verified': verified,
        'prices': prices,
        'nextStarts': nextStarts,
      };

  double priceFor(String duration) => prices[duration] ?? (prices.values.isNotEmpty ? prices.values.first : 0);

  List<String> generateSlots() {
    final List<String> out = [];
    for (int h = 10; h <= 16; h++) {
      out.add('${h.toString().padLeft(2, '0')}:00');
      out.add('${h.toString().padLeft(2, '0')}:30');
    }
    return out;
  }
}

List<Property> remoteProperties = [];

const mockProperties = <Property>[
  Property(
    id: 'p1',
    name: 'Homestay Thachi',
    imageAsset: 'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
    rating: 4.6,
    distanceKm: 0.8,
    verified: true,
    prices: {'30m': 99.0, '1h': 149.0, '2h': 249.0, '3h': 329.0, '4h': 389.0},
    nextStarts: const ['11:00', '11:30', '12:00', '12:30'],
  ),
  Property(
    id: 'p2',
    name: 'Village Room, Jibhi',
    imageAsset: 'https://flutter.github.io/assets-for-api-docs/assets/widgets/puffin.jpg',
    rating: 4.4,
    distanceKm: 1.2,
    verified: true,
    prices: {'30m': 89.0, '1h': 139.0, '2h': 229.0, '3h': 309.0, '4h': 369.0},
    nextStarts: const ['10:30', '11:00', '11:30'],
  ),
  Property(
    id: 'p3',
    name: 'Bir Hill Pod',
    imageAsset: 'https://flutter.github.io/assets-for-api-docs/assets/widgets/flamingos.jpg',
    rating: 4.5,
    distanceKm: 2.7,
    verified: false,
    prices: {'30m': 79.0, '1h': 129.0, '2h': 219.0, '3h': 289.0, '4h': 349.0},
    nextStarts: const ['12:00', '12:30', '13:00'],
  ),
];
