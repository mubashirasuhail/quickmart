import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';

// IMPORTANT: This Address class MUST be identical to the one in your CheckoutPage
// to ensure data consistency when passing between screens.
class Address {
  String? streetAddress;
  String? addressName;
  String? area;
  String? currentLocation; // For fetched location string
  double? latitude;
  double? longitude;
  String? myTextField; // New field for "My Textfield"

  Address({
    this.streetAddress,
    this.addressName,
    this.area,
    this.currentLocation,
    this.latitude,
    this.longitude,
    this.myTextField, // Initialize new field
  });

  // Factory constructor to create an Address object from a Firestore document
  factory Address.fromFirestore(Map<String, dynamic> data) {
    return Address(
      addressName: data['addressName'],
      streetAddress: data['streetAddress'],
      area: data['area'],
      myTextField: data['myTextField'], // Retrieve new field
    );
  }

  // Convert Address object to a map for storing in Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'addressName': addressName,
      'streetAddress': streetAddress,
      'area': area,
      'myTextField': myTextField, // Store new field
      // latitude and longitude are not typically saved for manual addresses in Firestore
      // unless you have a specific reason to do so.
    };
  }

  // Override == and hashCode for proper comparison in RadioListTile
  // This is crucial for RadioListTile to correctly identify the selected item
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    // Use null-aware operators for comparison to avoid errors if a property is null
    return other is Address &&
        runtimeType == other.runtimeType &&
        addressName == other.addressName &&
        streetAddress == other.streetAddress &&
        area == other.area &&
        currentLocation == other.currentLocation &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        myTextField == other.myTextField; // Include new field in comparison
  }

  @override
  int get hashCode =>
      Object.hash(addressName, streetAddress, area, currentLocation, latitude, longitude, myTextField);

  @override
  String toString() {
    // This will be used for display, combining available parts
    List<String> parts = [];
    if (addressName != null && addressName!.isNotEmpty) parts.add(addressName!);
    if (streetAddress != null && streetAddress!.isNotEmpty) parts.add(streetAddress!);
    if (area != null && area!.isNotEmpty) parts.add(area!);
    if (myTextField != null && myTextField!.isNotEmpty) parts.add(myTextField!); // Display new field
    if (currentLocation != null && currentLocation!.isNotEmpty) parts.add('(${currentLocation!})');

    return parts.isEmpty ? 'Unknown Address' : parts.join(', ');
  }
}

class AddressPage extends StatefulWidget {
  final Address? initialAddress;

  const AddressPage({super.key, this.initialAddress});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final TextEditingController _addressNameController = TextEditingController();
  final TextEditingController _streetAddressController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _myTextFieldController = TextEditingController(); // New controller

  String? _currentLocationDisplay; // Display text for current location
  Address? _currentLocationAddress; // The actual Address object for current location

  List<Address> _savedAddresses = [];
  Address? _selectedAddress; // To track the selected address (can be current or saved)

  bool _isFetchingLocation = false;
  bool _isSavingAddress = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // GlobalKey for the form in the add address dialog
  final _addAddressFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
    _selectedAddress = widget.initialAddress;

    // If initialAddress is a current location type, populate its display
    if (_selectedAddress != null && _selectedAddress!.currentLocation != null) {
      _currentLocationDisplay = _selectedAddress!.currentLocation;
      _currentLocationAddress = _selectedAddress; // Store it as the specific current location object
    } else if (_selectedAddress != null) {
      // If it's a saved address, populate the text controllers for editing
      _addressNameController.text = _selectedAddress!.addressName ?? '';
      _streetAddressController.text = _selectedAddress!.streetAddress ?? '';
      _areaController.text = _selectedAddress!.area ?? '';
      _myTextFieldController.text = _selectedAddress!.myTextField ?? ''; // Populate new field
    }
  }

  @override
  void dispose() {
    _addressNameController.dispose();
    _streetAddressController.dispose();
    _areaController.dispose();
    _myTextFieldController.dispose(); // Dispose new controller
    super.dispose();
  }

  Future<void> _loadSavedAddresses() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore.collection('addresses').get();
      setState(() {
        _savedAddresses = snapshot.docs.map((doc) {
          final data = doc.data();
          return Address.fromFirestore(data); // Use the fromFirestore factory
        }).toList();
      });
    } catch (e) {
      debugPrint('Error loading addresses: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load saved addresses.')),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
      _currentLocationDisplay = 'Fetching location...';
      _selectedAddress = null; // Deselect any previously selected address
      _currentLocationAddress = null; // Clear previous current location object
    });

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled. Please enable them.')),
        );
      }
      setState(() {
        _currentLocationDisplay = 'Location services disabled.';
        _isFetchingLocation = false;
      });
      return;
    }

    // Check for permissions.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied. Cannot get current location.')),
          );
        }
        setState(() {
          _currentLocationDisplay = 'Location permissions denied.';
          _isFetchingLocation = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Location permissions are permanently denied. Please enable them from app settings.')),
        );
      }
      setState(() {
        _currentLocationDisplay = 'Location permissions permanently denied.';
        _isFetchingLocation = false;
      });
      return;
    }

    // Permissions are granted, proceed to get location.
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high, timeLimit: const Duration(seconds: 10)); // Added time limit
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        // Construct a more readable address string (now without city, state, zip, country)
        final String addressString = [
          place.street,
          place.subLocality, // e.g., area
          // You might still want to include some general location info for current location
          // even if not explicitly stored in the Address object for saved addresses.
          // For instance, if you want a concise current location string:
          place.locality, // City from geocoding
          place.administrativeArea, // State from geocoding
          place.country, // Country from geocoding
        ].where((s) => s != null && s.isNotEmpty).join(', ');

        Address fetchedAddress = Address(
          addressName: 'Current Location', // A default name for current location
          currentLocation: addressString,
          streetAddress: place.street,
          area: place.subLocality,
          // Removed specific city, state, zip, country fields here
          latitude: position.latitude,
          longitude: position.longitude,
        );

        setState(() {
          _currentLocationDisplay = addressString;
          _currentLocationAddress = fetchedAddress; // Store the actual object
          _selectedAddress = fetchedAddress; // Select it
        });
      } else {
        setState(() {
          _currentLocationDisplay = 'Could not determine address from coordinates.';
          // Still create an Address object for selection, even if geocoding failed
          _currentLocationAddress = Address(
            currentLocation: _currentLocationDisplay,
            latitude: position.latitude,
            longitude: position.longitude,
          );
          _selectedAddress = _currentLocationAddress; // Select it even if geocoding fails
        });
      }
    } catch (e) {
      setState(() {
        _currentLocationDisplay = 'Error: Could not fetch location.';
        _currentLocationAddress = null;
        _selectedAddress = null;
      });
      debugPrint('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get current location: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingLocation = false;
        });
      }
    }
  }

  Future<void> _saveAddress() async {
    // Validate the form before proceeding to save
    if (_addAddressFormKey.currentState?.validate() == false) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill the all fields in the form.')),
        );
      }
      return;
    }

    setState(() {
      _isSavingAddress = true;
    });

    try {
      final newAddress = Address(
        addressName: _addressNameController.text,
        streetAddress: _streetAddressController.text,
        area: _areaController.text,
        myTextField: _myTextFieldController.text.isEmpty ? null : _myTextFieldController.text, // Save new field
      );

      await _firestore.collection('addresses').add(newAddress.toFirestore());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address saved successfully.')),
        );
        setState(() {
          _savedAddresses.add(newAddress);
          _selectedAddress = newAddress; // Select the newly added address
        });
        // Close the dialog and return the selected address to the previous screen
        Navigator.pop(context); // Close the add address dialog
        Navigator.pop(context, _selectedAddress); // Return to CheckoutPage
      }
    } catch (e) {
      debugPrint('Error saving address: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save address.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingAddress = false;
        });
      }
    }
  }

  void _showAddAddressDialog(BuildContext context) {
    // Clear controllers before showing the dialog
    _addressNameController.clear();
    _streetAddressController.clear();
    _areaController.clear();
    _myTextFieldController.clear(); // Clear new controller

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Wrap with StatefulBuilder to allow setState within the dialog
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Address'),
              content: SingleChildScrollView(
                // Wrap the Column with Form
                child: Form(
                  key: _addAddressFormKey, // Assign the GlobalKey to the Form
                  // Validation messages only appear after button press
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: _addressNameController,
                        decoration: const InputDecoration(
                            labelText: 'Address Name (e.g., Home, Office)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.label)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Address Name is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _streetAddressController,
                        decoration: const InputDecoration(
                            labelText: 'Street Address',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Street Address is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _areaController,
                        decoration: const InputDecoration(
                            labelText: 'Area/Locality',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.grid_on)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Area/Locality is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      // My Custom TextFormField
                      TextFormField(
                        controller: _myTextFieldController,
                        decoration: const InputDecoration(
                            labelText: 'Additional Notes / Instructions',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.edit)),
                        // This field is optional, so no validator is strictly needed
                        // If you want to make it required, add a validator similar to others.
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isSavingAddress
                      ? null
                      : () async {
                          setDialogState(() {
                            _isSavingAddress = true;
                          });
                          await _saveAddress();
                          if (mounted) {
                            setDialogState(() {
                              _isSavingAddress = false;
                            });
                          }
                        },
                  child: _isSavingAddress
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save Address'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine the text for the "Get Current Location" button
    final String currentLocationButtonText = _currentLocationAddress == null || _currentLocationAddress!.currentLocation == null
        ? 'Get Current Location'
        : 'Change Location';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Address'),
      ),
      body: SingleChildScrollView(
        // Wrap the entire body in SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0), // Add padding to the bottom
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddAddressDialog(context),
                    icon: const Icon(Icons.add_location_alt),
                    label: const Text('Add Address'),
                    style: ElevatedButton.styleFrom(
                      side: BorderSide.none,
                      foregroundColor: Colors.black, // Adjust as per your theme
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Current Location Section
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Your Current Location',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                              color: _selectedAddress == _currentLocationAddress
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade300,
                              width: _selectedAddress == _currentLocationAddress ? 2.0 : 1.0),
                        ),
                        child: RadioListTile<Address>(
                          title: Text(_currentLocationDisplay ?? 'No current location available'),
                          subtitle: _isFetchingLocation ? const LinearProgressIndicator() : null,
                          value: _currentLocationAddress ?? Address(currentLocation: 'Fetching...'),
                          groupValue: _selectedAddress,
                          onChanged: _isFetchingLocation
                              ? null // Disable onChanged while fetching location
                              : (Address? value) {
                                  setState(() {
                                    _selectedAddress = value;
                                  });
                                },
                          secondary: _isFetchingLocation
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : null,
                          controlAffinity: ListTileControlAffinity.trailing,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isFetchingLocation ? null : _getCurrentLocation,
                          icon: const Icon(Icons.location_on),
                          label: Text(currentLocationButtonText),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            foregroundColor: Theme.of(context).primaryColor,
                            side: BorderSide(color: Theme.of(context).primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(thickness: 1, indent: 16, endIndent: 16),
              // Saved Addresses Section
              _savedAddresses.isEmpty
                  ? Center(
                      // Changed to Center to center content within remaining space
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off, size: 50, color: Colors.grey.shade400),
                          const SizedBox(height: 10),
                          Text(
                            'No saved addresses yet!',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => _showAddAddressDialog(context),
                            icon: const Icon(Icons.add_location_alt),
                            label: const Text('Add New Address'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      // Keep Column if there are addresses
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            'Saved Addresses',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true, // Important: Allows ListView to take only needed height
                          physics:
                              const NeverScrollableScrollPhysics(), // Important: Prevents nested scrolling
                          itemCount: _savedAddresses.length,
                          itemBuilder: (context, index) {
                            final address = _savedAddresses[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                    color: _selectedAddress == address
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.shade300,
                                    width: _selectedAddress == address ? 2.0 : 1.0),
                              ),
                              child: RadioListTile<Address>(
                                title: Text(address.addressName ?? 'Address ${index + 1}',
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  // Ensure there are no double commas if a field is null/empty
                                  [
                                    address.streetAddress,
                                    address.area,
                                    address.myTextField, // Display new field in subtitle
                                  ].where((s) => s != null && s.isNotEmpty).join(', '),
                                ),
                                value: address,
                                groupValue: _selectedAddress,
                                onChanged: (Address? value) {
                                  setState(() {
                                    _selectedAddress = value;
                                  });
                                },
                                controlAffinity: ListTileControlAffinity.trailing,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedAddress == null
                        ? null // Disable if no address is selected
                        : () {
                            Navigator.pop(context, _selectedAddress); // Return the selected address
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Select Address'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}