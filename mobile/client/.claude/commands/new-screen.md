# Add a New Flutter Screen (Client App)

## Steps

### 1. Create the screen file
Create `lib/screens/<category>/<name>_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class <Name>Screen extends StatefulWidget {
  const <Name>Screen({super.key});

  @override
  State<<Name>Screen> createState() => _<Name>ScreenState();
}

class _<Name>ScreenState extends State<<Name>Screen> {
  bool _loading = true;
  dynamic _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      // final res = await ApiService.get<Something>();
      setState(() { _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('<Title>')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : const SizedBox(), // your content
    );
  }
}
```

### 2. Register the route in `lib/main.dart`
```dart
routes: {
  '/your-route': (context) => const <Name>Screen(),
}
```

### 3. Navigate to it
```dart
Navigator.pushNamed(context, '/your-route');
// With arguments:
Navigator.pushNamed(context, '/your-route', arguments: 'someId');
```

### 4. Add API method if needed
In `lib/services/api_service.dart`:
```dart
static Future<Map<String, dynamic>> getSomething(String id) async {
  return get('/endpoint/$id');
}
```
