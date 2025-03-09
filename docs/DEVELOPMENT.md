# Development Guide

This guide will help you set up the development environment for the Thesis Track API.

## Prerequisites

1. Go 1.21 or higher
2. PostgreSQL 14 or higher
3. Supabase account
4. Git

## Setting Up the Development Environment

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/thesis-track.git
cd thesis-track
```

### 2. Install Dependencies

```bash
go mod download
```

### 3. Set Up PostgreSQL

1. Create a new PostgreSQL database:
```sql
CREATE DATABASE thesis_track;
```

2. The tables will be automatically created by GORM when the application starts.

### 4. Set Up Supabase

1. Create a new Supabase project at https://supabase.com
2. Get your project URL and anon key from the project settings
3. Enable Email/Password authentication in Authentication > Providers
4. Create storage buckets for documents:
   - `thesis-drafts`
   - `thesis-finals`
   - `progress-documents`
5. Set up storage policies to restrict access

### 5. Configure Environment Variables

Create a `.env` file in the root directory:

```env
# Database
DB_HOST=localhost
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_NAME=thesis_track
DB_PORT=5432

# Supabase
SUPABASE_URL=your_project_url
SUPABASE_KEY=your_anon_key

# JWT
JWT_SECRET=your_jwt_secret

# Server
PORT=8080
```

### 6. Run the Application

```bash
go run cmd/main.go
```

The server will start at `http://localhost:8080`

## Development Workflow

### Code Structure

The project follows clean architecture principles:

1. **Domain Layer** (`internal/domain/`)
   - `entity/`: Domain models
   - `repository/`: Repository interfaces
   - `service/`: Service interfaces

2. **Infrastructure Layer** (`internal/infrastructure/`)
   - `database/`: Repository implementations   
   - `server/`: Server setup

3. **Application Layer** (`internal/application/`)
   - `handler/`: HTTP handlers
   - `middleware/`: HTTP middleware
   - `service/`: Service implementations
   - `repository/`: Repository implementations

4. **Entry Points** (`cmd/`)
   - Application entry point and initialization

### Adding New Features

1. **Define the Domain**
   - Add entity models in `internal/domain/entity/`
   - Add DTOs in `internal/domain/dto/`
   - Define repository interfaces in `internal/domain/repository/`
   - Define service interfaces in `internal/domain/service/`

2. **Implement Infrastructure**
   - Add routes in `internal/infrastructure/server/`
   - Add database connection in `internal/infrastructure/database/`

3. **Implement Application**
   - Add handlers in `internal/application/handler/`
   - Add middleware in `internal/application/middleware/`
   - Add services in `internal/application/service/`
   - Add repositories in `internal/application/repository/`

4. **Add Tests**
   - Write unit tests for each component
   - Add integration tests in `tests/`

### Testing

Run all tests:
```bash
go test ./...
```

Run specific tests:
```bash
go test ./tests/auth_test.go
```

### Code Style

The project follows standard Go code style guidelines:

1. Use `gofmt` to format code
2. Follow Go naming conventions
3. Add comments for exported functions and types
4. Use meaningful variable and function names

### Git Workflow

1. Create a new branch for each feature:
```bash
git checkout -b feature/feature-name
```

2. Make your changes and commit:
```bash
git add .
git commit -m "feat: add feature description"
```

3. Push your changes:
```bash
git push origin feature/feature-name
```

4. Create a pull request

### Commit Message Format

Follow the Conventional Commits specification:

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

Example:
```
feat: add thesis submission endpoint
```

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   - Check if PostgreSQL is running
   - Verify database credentials in `.env`
   - Ensure database exists

2. **Supabase Authentication Failed**
   - Verify Supabase URL and key
   - Check if authentication is enabled
   - Verify email templates

3. **File Upload Failed**
   - Check storage bucket permissions
   - Verify file size limits
   - Check storage policies

### Getting Help

1. Check the error logs
2. Review the documentation
3. Open an issue on GitHub
4. Contact the maintainers

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a pull request

## Resources

- [Go Documentation](https://golang.org/doc/)
- [GORM Documentation](https://gorm.io/docs/)
- [Fiber Documentation](https://docs.gofiber.io/)
- [Supabase Documentation](https://supabase.com/docs)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) 