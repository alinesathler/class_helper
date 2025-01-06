import '../shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_places_autocomplete_widgets/address_autocomplete_widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickerLocation extends StatefulWidget {
  @override
  State<PickerLocation> createState() => _PickerLocationState();
}

class _PickerLocationState extends State<PickerLocation> {
  static const GOOGLE_API_KEY = String.fromEnvironment('GOOGLE_API_KEY');

  void _onSuggestionClick(Place placeDetails) {
    final address =
        placeDetails.formattedAddressZipPlus4 ?? placeDetails.name ?? '';
    final coordinates = LatLng(
      placeDetails.lat ?? 0.0,
      placeDetails.lng ?? 0.0,
    );

    Navigator.pop(context, {"address": address, "coordinates": coordinates});
  }

  @override
  Widget build(BuildContext context) {
    if (GOOGLE_API_KEY.isEmpty) {
      return Center(
        child: Text(
          'GOOGLE_API_KEY is not set. Please set it in the environment variables',
          style: TextStyle(color: MyColors.onSurface),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Location',
            style: TextStyle(color: MyColors.onSurface, fontSize: 20),
          ),
          SizedBox(height: 10),
          AddressAutocompleteTextFormField(
            mapsApiKey: GOOGLE_API_KEY,
            debounceTime: 300,
            onSuggestionClick: _onSuggestionClick,
            decoration: InputDecoration(hintText: 'Address'),
          ),
        ],
      ),
    );
  }
}
