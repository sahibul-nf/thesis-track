import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:thesis_track_flutter_app/app/routes/app_routes.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';
import 'package:thesis_track_flutter_app/app/widgets/responsive_view.dart';
import 'package:thesis_track_flutter_app/app/widgets/toast.dart';

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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: ResponsiveView(
        smallView: _buildRegisterForm(theme, context),
        largeView: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 24,
            children: [
              _buildThumbnailImage(theme, context),
              // Register Form
              Form(
                key: _formKey,
                child: _buildRegisterForm(theme, context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailImage(ThemeData theme, BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/online-learning.svg',
              width: 300,
            ),
            const SizedBox(height: 24),
            Text(
              '"Your All-in-One Thesis Management Solution"',
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(),
            ),
            const SizedBox(height: 16),
            Text(
              'Track progress, manage deadlines, and collaborate \nseamlessly with your thesis supervisor.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm(ThemeData theme, BuildContext context) {
    return Flexible(
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Let's create an account",
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              // headline 2
              Text(
                "Enter your details to start your journey",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 50),
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: Icon(
                      Iconsax.user,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
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
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: Icon(
                      Iconsax.sms,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
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
              Obx(() => TextFormField(
                    controller: _passwordController,
                    obscureText: _isPasswordHidden.value,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Create a password',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 14, right: 10),
                        child: Icon(
                          Iconsax.lock,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordHidden.value
                              ? Iconsax.eye
                              : Iconsax.eye_slash,
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
              TextFormField(
                controller: _departmentController,
                decoration: InputDecoration(
                  labelText: 'Department',
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
                      TextFormField(
                        controller: _nimController,
                        decoration: InputDecoration(
                          labelText: 'Student ID (NIM)',
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
                      TextFormField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Login Year of Study',
                          hintText: 'Enter your login year',
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
              const SizedBox(height: 20),
              // Role Selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'You will be registered as ...',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: 'student',
                          label: Text('Student'),
                          icon: Icon(Iconsax.user),
                        ),
                        ButtonSegment(
                          value: 'lecture',
                          label: Text('Lecturer'),
                          icon: Icon(Iconsax.teacher),
                        ),
                      ],
                      selected: {_selectedRole.value},
                      onSelectionChanged: (Set<String> newSelection) {
                        _selectedRole.value = newSelection.first;
                      },
                      // style: TextButton.styleFrom(
                      //   visualDensity: VisualDensity.comfortable,
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(12),
                      //   ),
                      //   side: BorderSide(
                      //     color: theme.colorScheme.surfaceContainerHigh,
                      //     width: 1,
                      //   ),
                      // ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Register Button
              Obx(
                () => FilledButton(
                  onPressed: controller.isLoading
                      ? null
                      : () => _register(context, theme),
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
                ),
              ),
              const SizedBox(height: 20),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: theme.textTheme.bodySmall?.copyWith(
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _register(BuildContext context, ThemeData theme) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final errorMessage = await controller.register(
      email: _emailController.text,
      password: _passwordController.text,
      name: _nameController.text,
      role: _selectedRole.value,
      nidn: _selectedRole.value == 'lecture' ? _nidnController.text : null,
      department: _departmentController.text,
      nim: _selectedRole.value == 'student' ? _nimController.text : null,
      year: _selectedRole.value == 'student' ? _yearController.text : null,
    );

    if (errorMessage != null) {
      if (!context.mounted) return;
      MyToast.showShadcnUIToast(
        context,
        'Registration failed!',
        errorMessage,
        isError: true,
      );
      return;
    }

    if (!context.mounted) return;

    MyToast.showShadcnUIToast(
      context,
      'Registration successful!',
      'Please check your email to verify your account',
    );

    // Navigate to home screen
    context.go(RouteLocation.home);
  }
}
