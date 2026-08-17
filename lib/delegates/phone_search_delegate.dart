import 'package:flutter/material.dart';
import '../models/device.dart';
// ignore: unused_import
import 'package:http/http.dart' as http;
import '../services/phone_repository.dart';

class PhoneSearchDelegate extends SearchDelegate<Device?> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      return const Center(
        child: Text(
          'Type a device name (e.g., iPhone 15, Galaxy S24)',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return FutureBuilder<List<Device>>(
      future: PhoneRepository.search(cleanQuery),
      builder: (context, snapshot) {
        // 1. Loading State: Display spinner while fetching from local JSON / Proxy
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Searching local database & GSMArena...',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // 2. Error State
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Search failed. Check network connection.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        final results = snapshot.data ?? [];

        // 3. Empty Results State
        if (results.isEmpty) {
          return Center(
            child: Text(
              'No devices found for "$cleanQuery"',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        // 4. Success State: List of matching devices
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final device = results[index];
            return ListTile(
              leading: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: device.image.isNotEmpty
                    ? Image.network(
                        device.image,
                        fit: BoxFit.contain,
                        // ignore: unnecessary_underscores
                        errorBuilder: (_, __, ___) => const Icon(Icons.phone_android),
                      )
                    : const Icon(Icons.phone_android),
              ),
              title: Text(
                device.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${device.brand} • ${device.price}'),
              onTap: () => close(context, device),
            );
          },
        );
      },
    );
  }
}