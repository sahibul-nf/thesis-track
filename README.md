# Thesis Track API

A REST API for managing thesis progress tracking, built with Go using clean architecture principles.

## Technologies Used

- Go Fiber - Fast HTTP framework
- GORM - ORM library for Go
- PostgreSQL - Database
- Supabase - Authentication and file storage
- UUID - For unique identifiers

## Project Structure

```
thesis-track/
├── cmd/                    # Application entry points
├── config/                 # Configuration management
├── internal/              
│   ├── domain/             # Business logic and interfaces
│   │    ├── entity/        # Domain entities
│   │    ├── repository/    # Repository interfaces
│   │    └── service/       # Service interfaces
│   ├── infrastructure/     # Implementation of interfaces
│   │    ├── database/      # Database implementations
│   │    └── server/        # Server setup
│   └── application/        # Application logic
│   |    ├── handler/       # HTTP handlers
│   |    ├── middleware/    # HTTP middleware
│   |    ├── service/       # Service implementations
│   |    └── repository/    # Repository implementations
│   └── pkg/                # Shared packages
└── tests/                  # Test files
```

## Prerequisites

- Go 1.21 or higher
- PostgreSQL
- Supabase account and project

## Environment Variables

Create a `.env` file in the root directory with the following variables:

```env
DB_HOST=your_db_host
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_NAME=your_db_name
DB_PORT=your_db_port

SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_key

JWT_SECRET=your_jwt_secret
```

## API Endpoints

### Authentication

#### Register Student
- **POST** `/auth/register/student`
- **Body**:
  ```json
  {
    "name": "string",
    "email": "string",
    "password": "string",
    "nim": "string"
  }
  ```

#### Register Lecture
- **POST** `/auth/register/lecture`
- **Body**:
  ```json
  {
    "name": "string",
    "email": "string",
    "password": "string",
    "nip": "string"
  }
  ```

#### Login
- **POST** `/auth/login`
- **Body**:
  ```json
  {
    "email": "string",
    "password": "string"
  }
  ```

### Student Management

#### Create Student
- **POST** `/students`
- **Auth**: Required (Admin)
- **Body**:
  ```json
  {
    "name": "string",
    "email": "string",
    "nim": "string"
  }
  ```

#### Get Student
- **GET** `/students/{id}`
- **Auth**: Required

#### Update Student
- **PUT** `/students/{id}`
- **Auth**: Required (Owner/Admin)
- **Body**:
  ```json
  {
    "name": "string",
    "email": "string"
  }
  ```

### Lecture Management

#### Create Lecture
- **POST** `/lectures`
- **Auth**: Required (Admin)
- **Body**:
  ```json
  {
    "name": "string",
    "email": "string",
    "nip": "string"
  }
  ```

#### Get Lecture
- **GET** `/lectures/{id}`
- **Auth**: Required

#### Update Lecture
- **PUT** `/lectures/{id}`
- **Auth**: Required (Owner/Admin)
- **Body**:
  ```json
  {
    "name": "string",
    "email": "string"
  }
  ```

### Thesis Management

#### Submit Thesis
- **POST** `/theses`
- **Auth**: Required (Student)
- **Body**:
  ```json
  {
    "title": "string",
    "description": "string",
    "research_field": "string"
  }
  ```

#### Get Thesis
- **GET** `/theses/{id}`
- **Auth**: Required

#### Update Thesis
- **PUT** `/theses/{id}`
- **Auth**: Required (Owner)
- **Body**:
  ```json
  {
    "title": "string",
    "description": "string",
    "research_field": "string"
  }
  ```

### Progress Management

#### Add Progress
- **POST** `/progress`
- **Auth**: Required (Student)
- **Body**:
  ```json
  {
    "thesis_id": "string",
    "progress_description": "string"
  }
  ```

#### Get Progress
- **GET** `/progress/{id}`
- **Auth**: Required

#### Update Progress
- **PUT** `/progress/{id}`
- **Auth**: Required (Owner)
- **Body**:
  ```json
  {
    "progress_description": "string"
  }
  ```

#### Review Progress
- **POST** `/progress/{id}/review`
- **Auth**: Required (Lecture)
- **Body**:
  ```json
  {
    "status": "string",
    "comment": "string"
  }
  ```

### Document Management

#### Upload Draft Document
- **POST** `/documents/thesis/{thesisId}/draft`
- **Auth**: Required (Student)
- **Body**: multipart/form-data
  - document: file

#### Upload Final Document
- **POST** `/documents/thesis/{thesisId}/final`
- **Auth**: Required (Student)
- **Body**: multipart/form-data
  - document: file

#### Upload Progress Document
- **POST** `/documents/progress/{progressId}`
- **Auth**: Required (Student)
- **Body**: multipart/form-data
  - document: file

## Error Responses

All endpoints return errors in the following format:

```json
{
  "error": "error message"
}
```

Common HTTP status codes:
- 200: Success
- 201: Created
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 500: Internal Server Error

## Development

1. Clone the repository
```bash
git clone https://github.com/yourusername/thesis-track.git
```

2. Install dependencies
```bash
go mod download
```

3. Set up environment variables (see above)

4. Run the application
```bash
go run cmd/main.go
```

## Testing

Run tests with:
```bash
go test ./tests/...
```

## License

MIT License 