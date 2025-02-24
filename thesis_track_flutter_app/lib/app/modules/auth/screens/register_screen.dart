import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';

class RegisterScreen extends GetView<AuthController> {
  RegisterScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _departmentController = TextEditingController();
  final _nimController = TextEditingController();
  final _nidnController = TextEditingController();
  final _yearController = TextEditingController();
  final _isPasswordHidden = true.obs;
  final _selectedRole = 'student'.obs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: size.width > 450 ? 400 : size.width * 0.9,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Text(
                    'Create an account',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your details to get started',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Register Form
                  Form(
                    key: _formKey,
                    child: _buildRegisterForm(theme, context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm(ThemeData theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Role Selection
        Text(
          'Role',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'student',
                  label: Text('Student'),
                  icon: Icon(Iconsax.user),
                ),
                ButtonSegment(
                  value: 'lecturer',
                  label: Text('Lecturer'),
                  icon: Icon(Iconsax.teacher),
                ),
              ],
              selected: {_selectedRole.value},
              onSelectionChanged: (Set<String> newSelection) {
                _selectedRole.value = newSelection.first;
              },
            )),
        const SizedBox(height: 20),

        // Name Field
        Text(
          'Full Name',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Enter your full name',
            prefixIcon: Icon(
              Iconsax.user,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Email Field
        Text(
          'Email',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter your email',
            prefixIcon: Icon(
              Iconsax.sms,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!GetUtils.isEmail(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Password Field
        Text(
          'Password',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => TextFormField(
              controller: _passwordController,
              obscureText: _isPasswordHidden.value,
              decoration: InputDecoration(
                hintText: 'Create a password',
                prefixIcon: Icon(
                  Iconsax.lock,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordHidden.value ? Iconsax.eye : Iconsax.eye_slash,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: () =>
                      _isPasswordHidden.value = !_isPasswordHidden.value,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            )),
        const SizedBox(height: 20),

        // Department Field
        Text(
          'Department',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _departmentController,
          decoration: InputDecoration(
            hintText: 'Enter your department',
            prefixIcon: Icon(
              Iconsax.building,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your department';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Conditional Fields based on Role
        Obx(() {
          if (_selectedRole.value == 'student') {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Student ID (NIM)',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nimController,
                  decoration: InputDecoration(
                    hintText: 'Enter your NIM',
                    prefixIcon: Icon(
                      Iconsax.card,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your NIM';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Year',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter your year',
                    prefixIcon: Icon(
                      Iconsax.calendar,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your year';
                    }
                    return null;
                  },
                ),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Lecturer ID (NIDN)',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nidnController,
                  decoration: InputDecoration(
                    hintText: 'Enter your NIDN',
                    prefixIcon: Icon(
                      Iconsax.card,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your NIDN';
                    }
                    return null;
                  },
                ),
              ],
            );
          }
        }),
        const SizedBox(height: 24),

        // Register Button
        Obx(() => FilledButton(
              onPressed: controller.isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        final errorMessage = await controller.register(
                          email: _emailController.text,
                          password: _passwordController.text,
                          name: _nameController.text,
                          role: _selectedRole.value,
                          nidn: _selectedRole.value == 'lecturer'
                              ? _nidnController.text
                              : null,
                          department: _departmentController.text,
                          nim: _selectedRole.value == 'student'
                              ? _nimController.text
                              : null,
                          year: _selectedRole.value == 'student'
                              ? _yearController.text
                              : null,
                        );

                        if (errorMessage != null) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                        } else {
                          if (!context.mounted) return;
                          context.go('/');
                        }
                      }
                    },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: controller.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : const Text('Create Account'),
            )),
        const SizedBox(height: 24),

        // Login Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/login'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Login',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
