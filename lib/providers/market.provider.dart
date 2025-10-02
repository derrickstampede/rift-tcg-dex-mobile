import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:rift/models/market.model.dart';

part 'market.provider.g.dart';

// Cache for markets data
List<Market>? _cachedMarkets;
DateTime? _lastMarketsFetch;
const Duration _marketsCacheExpiry = Duration(hours: 24);

@riverpod
Future<List<Market>> market(MarketRef ref) async {
  try {
    // Check if we have cached data that's still valid
    if (_cachedMarkets != null && 
        _lastMarketsFetch != null && 
        DateTime.now().difference(_lastMarketsFetch!) < _marketsCacheExpiry) {
      print('Using cached markets data');
      return _cachedMarkets!;
    }

    final Map<String, String> httpHeaders = {"Content-Type": "application/json", "APIKey": dotenv.env['API_KEY']!};
    final url = Uri.https(dotenv.env['API']!, 'api/v1/markets/search');
    final response = await http.get(
      url,
      headers: httpHeaders,
    );
    
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> marketsData = responseData['data']['markets'] as List<dynamic>;
      final markets = marketsData.map((m) => Market.fromMap(m as Map<String, dynamic>)).toList();
      
      // Cache the result
      _cachedMarkets = markets;
      _lastMarketsFetch = DateTime.now();
      print('Markets data cached successfully');
      
      return markets;
    } else {
      // If request fails and we have cached data, use it as fallback
      if (_cachedMarkets != null) {
        print('Using cached markets data as fallback');
        return _cachedMarkets!;
      }
      throw Exception('Failed to load markets: HTTP ${response.statusCode}');
    }
  } catch (e) {
    print('Error loading markets: $e');
    // Use cached data as fallback if available
    if (_cachedMarkets != null) {
      print('Using cached markets data as fallback after error');
      return _cachedMarkets!;
    }
    throw Exception('Failed to load markets: $e');
  }
}
