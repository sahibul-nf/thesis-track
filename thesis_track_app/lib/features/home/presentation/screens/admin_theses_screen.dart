import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AdminThesesScreen extends StatelessWidget {
  const AdminThesesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thesis Overview'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search theses...',
                          prefixIcon: const Icon(PhosphorIconsRegular.magnifyingGlass),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: 'all',
                      items: [
                        DropdownMenuItem(value: 'all', child: Text('All Status')),
                        DropdownMenuItem(value: 'ongoing', child: Text('Ongoing')),
                        DropdownMenuItem(value: 'completed', child: Text('Completed')),
                        DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                      ],
                      onChanged: (value) {
                        // TODO: Implement status filter
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: 10, // TODO: Replace with actual thesis count
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(PhosphorIconsRegular.books),
                      ),
                      title: Text('Thesis ${index + 1}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Student: John Doe'),
                          Text('Supervisor: Dr. Jane Smith'),
                          Text('Status: ${index % 3 == 0 ? "Ongoing" : index % 3 == 1 ? "Completed" : "Rejected"}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(PhosphorIconsRegular.eye),
                            onPressed: () {
                              // TODO: Implement view thesis details
                            },
                          ),
                          IconButton(
                            icon: const Icon(PhosphorIconsRegular.pencil),
                            onPressed: () {
                              // TODO: Implement edit thesis functionality
                            },
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}