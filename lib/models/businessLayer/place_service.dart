import 'dart:convert';

import 'package:http/http.dart';
import 'package:user/models/businessLayer/global.dart' as global;

// For storing our result
class Place {
  String? streetNumber;
  String? street;
  String? city;
  String? zipCode;

  Place({
    this.streetNumber,
    this.street,
    this.city,
    this.zipCode,
  });

  @override
  String toString() {
    return 'Place(streetNumber: $streetNumber, street: $street, city: $city, zipCode: $zipCode)';
  }
}

class PlaceApiProvider {
  final client = Client();
  final String sessionToken;

  PlaceApiProvider(this.sessionToken);

  Future<List<Suggestion>?> fetchSuggestions(String input, String lang) async {
    lang = 'en';
    final request = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&language=$lang&key=${global.googleMap!.mapApiKey}&sessiontoken=$sessionToken';
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions'].map<Suggestion>((p) => Suggestion(p['place_id'], p['description'], '', '')).toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<Place> getPlaceDetailFromId(String placeId) async {
    final request = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=address_component&key=${global.googleMap!.mapApiKey}&sessiontoken=$sessionToken';
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        final components = result['result']['address_components'] as List<dynamic>;
        // build result
        final place = Place();
        for (var c in components) {
          final List type = c['types'];
          if (type.contains('street_number')) {
            place.streetNumber = c['long_name'];
          }
          if (type.contains('route')) {
            place.street = c['long_name'];
          }
          if (type.contains('locality')) {
            place.city = c['long_name'];
          }
          if (type.contains('postal_code')) {
            place.zipCode = c['long_name'];
          }
        }
        return place;
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}

class Suggestion {
  final String? placeId;
  final String? description;
  final String lat;
  final String lng;

  Suggestion(this.placeId, this.description, this.lat, this.lng);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}
