import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'Student';
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _idController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(PhosphorIconsRegular.user),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter user\'s full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(PhosphorIconsRegular.envelope),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter user\'s email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(PhosphorIconsRegular.identificationCard),
                ),
                value: _selectedRole,
                items: ['Student', 'Lecturer', 'Admin']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                      _idController.clear();
                    });
                  }
                },
              ),
              if (_selectedRole != 'Admin') ...[  
                const SizedBox(height: 16),
                TextFormField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: _selectedRole == 'Student' ? 'Student ID (NIM)' : 'Lecturer ID (NIDN)',
                    prefixIcon: const Icon(PhosphorIconsRegular.identificationBadge),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter ${_selectedRole == 'Student' ? 'student' : 'lecturer'} ID';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // TODO: Implement user creation
                    context.pop();
                  }
                },
                icon: const Icon(PhosphorIconsRegular.userPlus),
                label: const Text('Add User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}