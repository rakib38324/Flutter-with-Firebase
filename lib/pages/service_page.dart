import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

// Main Service Page (Stateful because data changes)
class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {

  // Reference to "services" in Firebase Realtime Database
  final DatabaseReference serviceRef =
  FirebaseDatabase.instance.ref().child("services");

  // Predefined icons user can select
  final Map<String, IconData> iconOptions = {
    "Car Rental": Icons.car_rental,
    "Support": Icons.support_agent,
    "Pickup/Drop": Icons.location_on,
    "Payment": Icons.payment,
    "Other": Icons.miscellaneous_services,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top AppBar
      appBar: AppBar(
        title: const Text("Our Services"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      // Floating button to add a new service
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: () {
          _openServiceForm(context); // Open form to add a service
        },
      ),

      // Body shows list of services from Firebase
      body: StreamBuilder(
        stream: serviceRef.onValue, // Listen for real-time changes
        builder: (context, snapshot) {
          // Show error if something goes wrong
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading services"));
          }

          // Show message if no data exists
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: Text("No services available"));
          }

          // Convert Firebase snapshot to a list
          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final items = data.values.toList();

          // Display list of services
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20), // space between cards
            itemBuilder: (context, index) {
              final service = items[index];

              // Build a card for each service
              return _serviceCard(
                service["id"],                     // service id
                service["iconName"] ?? "Other",    // icon name, default Other
                service["title"],                  // service title
                service["subtitle"],               // service subtitle
              );
            },
          );
        },
      ),
    );
  }

  // --------------------- SERVICE CARD ---------------------
  // Card for each service with icon, title, subtitle, edit/delete
  Widget _serviceCard(String id, String iconName, String title, String subtitle) {
    return Card(
      elevation: 4, // shadow under card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // rounded edges
      child: Padding(
        padding: const EdgeInsets.all(20), // space inside card
        child: Row(
          children: [
            // Display service icon
            Icon(iconOptions[iconName] ?? Icons.miscellaneous_services,
                size: 40, color: Colors.blue),
            const SizedBox(width: 20), // space between icon and text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service title
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  // Service subtitle/description
                  Text(subtitle, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            // Edit and Delete buttons
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.green),
                  onPressed: () {
                    // Open form to edit existing service
                    _openServiceForm(context,
                        id: id, title: title, subtitle: subtitle, iconName: iconName);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteService(id), // Delete service
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --------------------- CREATE + UPDATE FORM ---------------------
  void _openServiceForm(BuildContext context,
      {String? id, String? title, String? subtitle, String? iconName}) {
    // Controllers to get input text
    final titleController = TextEditingController(text: title);
    final subtitleController = TextEditingController(text: subtitle);
    String selectedIconName = iconName ?? iconOptions.keys.first; // default first icon

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(id == null ? "Add Service" : "Edit Service"), // title changes for add/edit
        content: Column(
          mainAxisSize: MainAxisSize.min, // shrink to fit content
          children: [
            // Title input
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            // Subtitle input
            TextField(
              controller: subtitleController,
              decoration: const InputDecoration(labelText: "Subtitle"),
            ),
            const SizedBox(height: 10),
            // Dropdown to select icon visually
            DropdownButtonFormField<String>(
              value: selectedIconName, // current selected icon
              decoration: const InputDecoration(labelText: "Select Icon"),
              items: iconOptions.keys
                  .map((name) => DropdownMenuItem(
                value: name,
                child: Row(
                  children: [
                    Icon(iconOptions[name], color: Colors.blue), // show icon
                    const SizedBox(width: 10),
                    Text(name), // show name
                  ],
                ),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedIconName = value; // update selected icon
                }
              },
            ),
          ],
        ),
        actions: [
          // Cancel button
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          // Add or Update button
          ElevatedButton(
            onPressed: () {
              final sid = id ?? DateTime.now().millisecondsSinceEpoch.toString(); // unique id

              final serviceData = {
                "id": sid,
                "title": titleController.text,
                "subtitle": subtitleController.text,
                "iconName": selectedIconName, // store icon name
              };

              serviceRef.child(sid).set(serviceData); // save to Firebase
              Navigator.pop(context); // close dialog
            },
            child: Text(id == null ? "Add" : "Update"),
          ),
        ],
      ),
    );
  }

  // --------------------- DELETE SERVICE ---------------------
  void _deleteService(String id) async {
    await serviceRef.child(id).remove(); // remove from Firebase
  }
}
