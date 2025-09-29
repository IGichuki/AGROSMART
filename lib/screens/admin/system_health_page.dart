import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SystemSettingsPage extends StatefulWidget {
  const SystemSettingsPage({Key? key}) : super(key: key);

  @override
  State<SystemSettingsPage> createState() => _SystemSettingsPageState();
}

class _SystemSettingsPageState extends State<SystemSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _newCropController = TextEditingController();
  String? selectedCrop;
  final Map<String, dynamic> thresholds = {
    'soilMoistureMin': 20,
    'soilMoistureMax': 40,
    'irrigationDuration': 30,
    'humidityRange': '40-60%',
  };

  Future<List<String>> _fetchCrops() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('cropThresholds')
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> _addNewCrop(String cropName) async {
    try {
      await FirebaseFirestore.instance
          .collection('cropThresholds')
          .doc(cropName)
          .set({
            'soilMoistureMin': 20,
            'soilMoistureMax': 40,
            'irrigationDuration': 30,
            'humidityRange': '40-60%',
          });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Crop "$cropName" added successfully!')),
      );
      setState(() {}); // Refresh the crop list
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add crop: $e')));
    }
  }

  Future<void> _deleteCrop(String cropName) async {
    try {
      await FirebaseFirestore.instance
          .collection('cropThresholds')
          .doc(cropName)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Crop "$cropName" deleted successfully!')),
      );
      setState(() {
        if (selectedCrop == cropName) {
          selectedCrop = null;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete crop: $e')));
    }
  }

  Future<void> _loadThresholds(String cropName) async {
    final doc = await FirebaseFirestore.instance
        .collection('cropThresholds')
        .doc(cropName)
        .get();
    if (doc.exists) {
      setState(() {
        selectedCrop = cropName;
        thresholds['soilMoistureMin'] = doc['soilMoistureMin'] ?? 20;
        thresholds['soilMoistureMax'] = doc['soilMoistureMax'] ?? 40;
        thresholds['irrigationDuration'] = doc['irrigationDuration'] ?? 30;
        thresholds['humidityRange'] = doc['humidityRange'] ?? '40-60%';
      });
    }
  }

  void _updateThresholds() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        await FirebaseFirestore.instance
            .collection('cropThresholds')
            .doc(selectedCrop)
            .update(thresholds);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thresholds updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update thresholds: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF43cea2), Color(0xFF185a9d)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add New Crop',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newCropController,
                            decoration: InputDecoration(
                              labelText: 'Crop Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            final cropName = _newCropController.text.trim();
                            if (cropName.isNotEmpty) {
                              _addNewCrop(cropName);
                              _newCropController.clear();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    const Divider(height: 32, thickness: 1),
                    FutureBuilder<List<String>>(
                      future: _fetchCrops(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return const Text('Error loading crops');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text('No crops available');
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                value: selectedCrop,
                                items: snapshot.data!
                                    .map(
                                      (crop) => DropdownMenuItem(
                                        value: crop,
                                        child: Text(crop),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    _loadThresholds(value);
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: 'Select Crop',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: selectedCrop != null
                                    ? () => _deleteCrop(selectedCrop!)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Delete Selected Crop'),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    if (selectedCrop != null)
                      Expanded(
                        child: Form(
                          key: _formKey,
                          child: ListView(
                            children: [
                              _buildThresholdField(
                                label: 'Soil Moisture Min (%)',
                                initialValue: thresholds['soilMoistureMin']
                                    .toString(),
                                onSaved: (value) =>
                                    thresholds['soilMoistureMin'] = int.parse(
                                      value!,
                                    ),
                              ),
                              _buildThresholdField(
                                label: 'Soil Moisture Max (%)',
                                initialValue: thresholds['soilMoistureMax']
                                    .toString(),
                                onSaved: (value) =>
                                    thresholds['soilMoistureMax'] = int.parse(
                                      value!,
                                    ),
                              ),
                              _buildThresholdField(
                                label: 'Irrigation Duration (mins)',
                                initialValue: thresholds['irrigationDuration']
                                    .toString(),
                                onSaved: (value) =>
                                    thresholds['irrigationDuration'] =
                                        int.parse(value!),
                              ),
                              _buildThresholdField(
                                label: 'Humidity Range (%)',
                                initialValue: thresholds['humidityRange'],
                                onSaved: (value) =>
                                    thresholds['humidityRange'] = value!,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (selectedCrop != null)
                      ElevatedButton(
                        onPressed: _updateThresholds,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Update Thresholds'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThresholdField({
    required String label,
    required String initialValue,
    required void Function(String?) onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Enter $label' : null,
        onSaved: onSaved,
      ),
    );
  }
}
