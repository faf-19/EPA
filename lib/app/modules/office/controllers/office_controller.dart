import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class OfficeLocation {
  final String name;
  final String address;
  final String phone;
  final String email;
  final LatLng position;

  const OfficeLocation({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.position,
  });
}

class OfficeController extends GetxController {
  final RxString searchQuery = ''.obs;
  final Rxn<OfficeLocation> selectedOffice = Rxn<OfficeLocation>();

  static const List<OfficeLocation> _offices = [
    OfficeLocation(
      name: 'Addis Ketema',
      address: 'Addis Ketema Subcity Woreda 01',
      phone: '+251 11 123 4567',
      email: 'addisketema@epa.gov.et',
      position: LatLng(9.043846, 38.74831),
    ),
    OfficeLocation(
      name: 'Kolfe Keranio',
      address: 'Kolfe Keranio Woreda 05',
      phone: '+251 11 765 4321',
      email: 'kolfe@epa.gov.et',
      position: LatLng(9.042328, 38.680172),
    ),
    OfficeLocation(
      name: 'Bole',
      address: 'Bole Subcity Office',
      phone: '+251 11 555 1010',
      email: 'bole@epa.gov.et',
      position: LatLng(8.99884, 38.789996),
    ),
    OfficeLocation(
      name: 'Lideta',
      address: 'Ras Desta Damtew St.',
      phone: '+251 11 778 3344',
      email: 'lideta@epa.gov.et',
      position: LatLng(9.024019, 38.738265),
    ),
    OfficeLocation(
      name: 'Arada',
      address: 'Churchill Ave.',
      phone: '+251 11 987 6543',
      email: 'arada@epa.gov.et',
      position: LatLng(9.035494, 38.757194),
    ),
    OfficeLocation(
      name: 'Yeka',
      address: 'CMC Road',
      phone: '+251 11 345 6789',
      email: 'yeka@epa.gov.et',
      position: LatLng(9.00988, 38.825188),
    ),
    OfficeLocation(
      name: 'Lemi Kura',
      address: 'Ayat Roundabout',
      phone: '+251 11 222 8899',
      email: 'lemikura@epa.gov.et',
      position: LatLng(9.053911, 38.858372),
    ),
  ];

  List<OfficeLocation> get offices => _offices;

  LatLng get initialCenter => const LatLng(9.025167, 38.758888);

  List<OfficeLocation> get filteredOffices {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      return _offices;
    }
    return _offices
        .where(
          (office) =>
              office.name.toLowerCase().contains(query) ||
              office.address.toLowerCase().contains(query),
        )
        .toList();
  }

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  void selectOffice(OfficeLocation office) {
    selectedOffice.value = office;
  }

  void clearSelection() {
    selectedOffice.value = null;
  }
}
