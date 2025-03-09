# Thesis Track Flutter App

A modern Flutter application for managing thesis tracking and progress monitoring. Built with Material 3 design principles and a focus on clean, maintainable architecture.

## Features

- Authentication (Login/Register)
- Thesis Management
  - Submit new thesis
  - View thesis details
  - Track thesis progress
  - Manage supervisors and examiners
- Progress Tracking
  - Add progress updates
  - Review progress
  - Comment system
- Document Management
  - Upload draft documents
  - Upload final documents

## Tech Stack

- Flutter
- GetX (State Management)
- Go Router (Navigation)
- Material 3 Layout
- Google Fonts (Poppins)

## Project Structure

```
lib/
├── app/
│   ├── bindings/       # Dependency injection
│   ├── config/         # App configuration
│   ├── core/           # Core functionality
│   ├── data/           # Data layer
│   │   ├── models/     # Data models
│   │   ├── providers/  # API providers
│   │   └── services/   # Business logic
│   ├── modules/        # Feature modules
│   │   ├── auth/       # Authentication
│   │   ├── thesis/     # Thesis management
│   │   └── progress/   # Progress tracking
│   ├── routes/         # Route definitions
│   ├── theme/          # App theme
│   └── widgets/        # Reusable widgets
└── main.dart
```

## TODO List

### Setup & Configuration
- [ ] Initialize Flutter project
- [ ] Add required dependencies
- [ ] Setup project structure
- [ ] Configure theme and colors
- [ ] Setup routing

### Authentication Module
- [ ] Login screen
- [ ] Registration screen
- [ ] Auth service implementation
- [ ] Token management

### Thesis Module
- [ ] Thesis list view
- [ ] Thesis detail view
- [ ] Submit thesis form
- [ ] Thesis status management

### Progress Module
- [ ] Progress list view
- [ ] Add progress form
- [ ] Progress review interface
- [ ] Comment system implementation

### Document Management
- [ ] Document upload interface
- [ ] Document preview
- [ ] File management system

### UI/UX
- [ ] Implement Material 3 layout
- [ ] Design system setup
- [ ] Responsive layouts
- [ ] Loading states
- [ ] Error handling

### Testing
- [ ] Unit tests
- [ ] Widget tests
- [ ] Integration tests

### Documentation
- [ ] Code documentation
- [ ] API integration guide
- [ ] User guide

## Getting Started

1. Clone the repository
2. Install dependencies:
```bash
flutter pub get
```
3. Run the app:
```bash
flutter run
```

## Development Status

Current development status and progress tracking will be updated here.

## Contributing

Guidelines for contributing to the project will be added here.

## License

This project is licensed under the MIT License.
