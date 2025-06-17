import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart'; // Keep if you still need location logic somewhere
import 'package:geocoding/geocoding.dart'; // Keep if you still need location logic somewhere

// IMPORTANT: This Address class MUST be identical to the one in your CheckoutPage
// and AddressPage to ensure data consistency when passing between screens.
// In a larger project, this would ideally be in a separate file (e.g., models/address.dart)
// and imported where needed.
class Address {
  String? id; // Added to store the Firestore document ID
  String? streetAddress;
  String? addressName;
  String? area;
  String?
      currentLocation; // For fetched location string (used in original AddressPage)
  double? latitude; // (used in original AddressPage)
  double? longitude; // (used in original AddressPage)
  String? myTextField; // New field for "My Textfield"

  Address({
    this.id, // Initialize it
    this.streetAddress,
    this.addressName,
    this.area,
    this.currentLocation,
    this.latitude,
    this.longitude,
    this.myTextField, // Initialize new field
  });

  // Factory constructor to create an Address object from a Firestore document
  // Now accepts DocumentSnapshot to get the ID and data
  factory Address.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Address(
      id: doc.id, // Capture the document ID here!
      addressName: data?['addressName'],
      streetAddress: data?['streetAddress'],
      area: data?['area'],
      myTextField: data?['myTextField'],
      // currentLocation, latitude, longitude are typically not saved in Firestore for manual addresses,
      // so they are not included in fromFirestore or toFirestore for manual addresses.
    );
  }

  // Convert Address object to a map for storing in Firestore
  // Note: 'id' is not stored in the document itself, it's the document's key.
  Map<String, dynamic> toFirestore() {
    return {
      'addressName': addressName,
      'streetAddress': streetAddress,
      'area': area,
      'myTextField': myTextField,
    };
  }

  // Override == and hashCode for proper comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    // Crucial: Compare by ID if available, otherwise by other fields
    // For Firestore documents, comparing by ID is the most robust and accurate way.
    return other is Address && runtimeType == other.runtimeType && id == other.id;
  }

  @override
  int get hashCode {
    // Corrected hashCode implementation.
    // If 'id' is guaranteed to be unique and non-null for persistent objects,
    // hashing only by 'id' is sufficient.
    // Use the null-aware operator '?' to safely call hashCode on id.
    // If 'id' can legitimately be null for unsaved Address objects,
    // you might want to fall back to hashing other fields or a constant for null.
    return id.hashCode;
  }

  @override
  String toString() {
    List<String> parts = [];
    if (addressName != null && addressName!.isNotEmpty) parts.add(addressName!);
    if (streetAddress != null && streetAddress!.isNotEmpty)
      parts.add(streetAddress!);
    if (area != null && area!.isNotEmpty) parts.add(area!);
    if (myTextField != null && myTextField!.isNotEmpty) parts.add(myTextField!);
    if (currentLocation != null && currentLocation!.isNotEmpty)
      parts.add('(${currentLocation!})');

    return parts.isEmpty ? 'Unknown Address' : parts.join(', ');
  }
}

//--- The SavedAddressesListPage ---

class SavedAddressesListPage extends StatefulWidget {
  const SavedAddressesListPage({super.key});

  @override
  State<SavedAddressesListPage> createState() => _SavedAddressesListPageState();
}

class _SavedAddressesListPageState extends State<SavedAddressesListPage> {
  List<Address> _savedAddresses = [];
  bool _isLoading = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _addressNameController = TextEditingController();
  final TextEditingController _streetAddressController =
      TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _myTextFieldController = TextEditingController();

  // GlobalKey for the form to manage validation
  final _formKey = GlobalKey<FormState>();

  // Track if saving/updating is in progress (for the dialog's button)
  bool _isSavingOrUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
  }

  @override
  void dispose() {
    _addressNameController.dispose();
    _streetAddressController.dispose();
    _areaController.dispose();
    _myTextFieldController.dispose();
    super.dispose();
  }

  // Fetches saved addresses from Firestore
  Future<void> _loadSavedAddresses() async {
    setState(() {
      _isLoading = true;
    });
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('addresses').get();
      setState(() {
        _savedAddresses = snapshot.docs.map((doc) {
          return Address.fromFirestore(
              doc); // Pass the DocumentSnapshot to capture ID
        }).toList();
      });
    } catch (e) {
      debugPrint('Error loading addresses: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load saved addresses.')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handles both adding a new address and updating an existing one
  Future<void> _saveOrUpdateAddress({Address? addressToEdit}) async {
    // Validate the form before proceeding to save/update
    // This will trigger the validator for each TextFormField
    if (_formKey.currentState?.validate() == false) {
      // If validation fails, do not proceed with saving/updating.
      // The error messages will now be displayed below the TextFormFields.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please fill all fields in the form.')),
        );
      }
      return;
    }

    try {
      // Create a map from the current controller values
      final Map<String, dynamic> addressDataToSave = {
        'addressName': _addressNameController.text,
        'streetAddress': _streetAddressController.text,
        'area': _areaController.text,
        'myTextField': _myTextFieldController.text.isEmpty
            ? null
            : _myTextFieldController.text,
      };

      if (addressToEdit != null && addressToEdit.id != null) {
        // --- UPDATE EXISTING ADDRESS ---
        await _firestore
            .collection('addresses')
            .doc(addressToEdit.id)
            .update(addressDataToSave);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address updated successfully.')),
          );
        }
      } else {
        // --- ADD NEW ADDRESS ---
        await _firestore.collection('addresses').add(addressDataToSave);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address added successfully.')),
          );
        }
      }

      // After successful add/update, reload the list and close the dialog
      await _loadSavedAddresses(); // Reload addresses to reflect changes from Firestore
      if (mounted) {
        Navigator.of(context).pop(); // Close the add/edit address dialog
      }
    } catch (e) {
      debugPrint('Error saving/updating address: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save/update address: $e')),
        );
      }
    } finally {
      // The _isSavingOrUpdating flag should be reset after the operation completes,
      // which is done in the .then() callback of the _saveOrUpdateAddress call.
    }
  }

  // Shows the dialog for adding a new address or editing an existing one
  void _showAddEditAddressDialog({Address? address}) {
    // Clear controllers first
    _addressNameController.clear();
    _streetAddressController.clear();
    _areaController.clear();
    _myTextFieldController.clear();

    String dialogTitle = 'Add New Address';
    // If an address is passed, it means we are in edit mode
    if (address != null) {
      dialogTitle = 'Edit Address';
      _addressNameController.text = address.addressName ?? '';
      _streetAddressController.text = address.streetAddress ?? '';
      _areaController.text = address.area ?? '';
      _myTextFieldController.text = address.myTextField ?? '';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // StatefulBuilder allows us to call setState within the dialog
        // to update its UI (e.g., button loading state)
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(dialogTitle),
              content: SingleChildScrollView(
                // Wrap the Column with Form
                child: Form(
                  key: _formKey, // Assign the GlobalKey to the Form
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
                      TextFormField(
                        controller: _myTextFieldController,
                        decoration: const InputDecoration(
                            labelText: 'Additional Notes / Instructions',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.edit)),
                        // This field is optional, so no validator is needed
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  // Disable button if an operation is in progress
                  onPressed: _isSavingOrUpdating
                      ? null
                      : () async {
                          // Before calling _saveOrUpdateAddress, set the loading state
                          // and then call _saveOrUpdateAddress.
                          setDialogState(() {
                            _isSavingOrUpdating = true;
                          });

                          // Await the save/update operation
                          await _saveOrUpdateAddress(addressToEdit: address);

                          // After the operation completes (successfully or with error),
                          // reset the loading state.
                          if (mounted) {
                            setDialogState(() {
                              _isSavingOrUpdating = false;
                            });
                          }
                        },
                  child: _isSavingOrUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          address != null ? 'Update Address' : 'Save Address'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Handles the logic for editing a specific address
  void _editAddress(Address address) {
    _showAddEditAddressDialog(
        address: address); // Call with the address to pre-fill and update
  }

  // Handles the logic for deleting a specific address
  Future<void> _deleteAddress(Address address) async {
    // Ensure we have an ID to delete from Firestore
    if (address.id == null) {
      debugPrint('Error: Address ID is null, cannot delete.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error: Cannot delete address without an ID.')),
        );
      }
      return;
    }

    // Show a confirmation dialog before deleting
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Address'),
          content: Text(
              'Are you sure you want to delete "${address.addressName}"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(false), // User canceled
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(true), // User confirmed
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    // If user confirmed deletion
    if (confirm == true) {
      try {
        // Delete from Firestore using the document ID
        await _firestore.collection('addresses').doc(address.id).delete();
        // Remove from local list for immediate UI update
        setState(() {
          _savedAddresses.removeWhere((item) => item.id == address.id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Address "${address.addressName}" deleted successfully.')),
          );
        }
      } catch (e) {
        debugPrint('Error deleting address from Firestore: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete address: $e')),
          );
          // In case of error, reload the list to ensure data consistency with Firestore
          _loadSavedAddresses();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Saved Addresses'),
        actions: [
          // Button to add a new address
          IconButton(
            icon: const Icon(Icons.add_location_alt),
            onPressed: () =>
                _showAddEditAddressDialog(), // Call without an address for adding
            tooltip: 'Add New Address',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : _savedAddresses.isEmpty
              ? Center(
                  // Display message if no addresses are saved
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off,
                          size: 50, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text(
                        'No saved addresses yet!',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () =>
                            _showAddEditAddressDialog(), // Button to add first address
                        icon: const Icon(Icons.add_location_alt),
                        label: const Text('Add Your First Address'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  // Display list of saved addresses
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _savedAddresses.length,
                  itemBuilder: (context, index) {
                    final address = _savedAddresses[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        // Use Stack to position icons on the card
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  address.addressName ?? 'Address ${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (address.streetAddress != null &&
                                    address.streetAddress!.isNotEmpty)
                                  Text(address.streetAddress!),
                                if (address.area != null &&
                                    address.area!.isNotEmpty)
                                  Text(address.area!),
                                if (address.myTextField != null &&
                                    address.myTextField!.isNotEmpty)
                                  Text(' ${address.myTextField!}'),
                                const SizedBox(
                                    height:
                                        10), // Add some space at the bottom
                              ],
                            ),
                          ),
                          // Edit Icon (positioned bottom right)
                          Positioned(
                            top: 8, // Changed from top to bottom
                            right:
                                10, // Adjusted to prevent overlap with delete button
                            child: IconButton(
                              icon: Image.asset(
                                'assets/images/edit.png',
                                width: 24, // Adjust width as needed
                                height: 24, // Adjust height as needed
                                // color: Colors
                                //     .red, // You can still apply a color tint if your PNG is grayscale
                              ),
                              onPressed: () =>
                                  _editAddress(address), // Call delete method
                              tooltip: 'Edit Address',
                            ),
                          ),
                          // Delete Icon (positioned bottom right, further to the right)
                          Positioned(
                              bottom: 8, // Changed from top to bottom
                              right: 8,
                              child: IconButton(
                                icon: Image.asset(
                                  'assets/images/delete.png', // Your image path
                                  width: 24, // Adjust width as needed
                                  height: 24, // Adjust height as needed
                                  //color: Colors
                                  // .red, // You can still apply a color tint if your PNG is grayscale
                                ),
                                onPressed: () => _deleteAddress(
                                    address), // Call delete method
                                tooltip: 'Delete Address',
                              )),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}