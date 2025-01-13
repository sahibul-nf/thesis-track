# Thesis Track API Documentation

## Authentication

All protected endpoints require a JWT token in the Authorization header:

```
Authorization: Bearer <token>
```

### Register

Register a new account (Student, Lecture, Admin).

**Endpoint**: `POST /auth/register`

**Request Body**:

```json
{
  "email": "string",
  "password": "string",
  "name": "string",
  "role": "string (Student/Lecture/Admin)",
  "nidn": "string (required for Lecture)",
  "department": "string (required for Student and Lecture)",
  "nim": "string (required for Student)",
  "year": "string (required for Student)"
}
```

**Response (201)**:

```json
{
  "data": {
    "id": "uuid",
    "email": "string",
    "role": "string",
    "user": {
      "id": "uuid",
      "name": "string",
      "nim": "string",
      "email": "string",
      "department": "string",
      "year": "string",
      "created_at": "timestamp",
      "updated_at": "timestamp"
    }
  }
}
```

### Login

Login with email and password.

**Endpoint**: `POST /auth/login`

**Request Body**:

```json
{
  "email": "string",
  "password": "string"
}
```

**Response (200)**:

```json
{
  "data": {
    "access_token": "string",
    "refresh_token": "string",
    "expires_in": "int",
    "expires_at": "int",
    "role": "string",
    "user": {
      "id": "uuid",
      "name": "string",
      "nim": "string",
      "email": "string",
      "department": "string",
      "year": "string",
      "created_at": "timestamp",
      "updated_at": "timestamp"
    }
  }
}
```

## Student Management

### Get Student

Get student details by ID.

**Endpoint**: `GET /students/{id}`

**Auth**: Required

**Response (200)**:

```json
{
  "data": {
    "id": "uuid",
    "name": "string",
    "email": "string",
    "nim": "string",
    "department": "string",
    "year": "string",
    "created_at": "timestamp",
    "updated_at": "timestamp"
  }
}
```

### Update Student

Update student details.

**Endpoint**: `PUT /students/{id}`

**Auth**: Required (Owner/Admin)

**Request Body**:

```json
{
  "name": "string",
  "email": "string",
  "nim": "string",
  "department": "string",
  "year": "string"
}
```

**Response (200)**:

```json
{
  "data": {
    "id": "uuid",
    "name": "string",
    "email": "string",
    "nim": "string",
    "department": "string",
    "year": "string",
    "created_at": "timestamp",
    "updated_at": "timestamp"
  }
}
```

## Thesis Management

### Submit Thesis

Submit a new thesis.

**Endpoint**: `POST /theses`

**Auth**: Required (Student)

**Request Body**:

```json
{
  "title": "string",
  "abstract": "string",
  "research_field": "string",
}
```

**Response (201)**:

```json
{
	"data": {
		"id": "uuid",
		"student_id": "uuid",
		"title": "string",
		"abstract": "string",
		"research_field": "string",
		"status": "Proposed",
		"submission_date": "timestamp",
		"draft_document_url": "string",
		"final_document_url": "string",
		"student": {
			"id": "uuid",
			"name": "string",
			"nim": "string",
			"email": "string",
			"department": "string",
			"year": "string",
			"created_at": "timestamp",
			"updated_at": "timestamp"
		},
		"supervisors": [
			{
				"id": "uuid",
				"name": "string",
				"email": "string",
				"nidn": "string",
				"department": "string",
			}
		],
		"examiners": [
			{
				"id": "uuid",
				"name": "string",
				"email": "string",
				"nidn": "string",
				"department": "string",
			}
		],
		"created_at": "timestamp",
		"updated_at": "timestamp"
	}
}
```

### Get Thesis

Get thesis details by ID.

**Endpoint**: `GET /theses/{id}`

**Auth**: Required

**Response (200)**:

```json
{
  "data": {
    "id": "uuid",
    "title": "string",
    "description": "string",
    "research_field": "string",
    "status": "string",
    "student_id": "uuid",
    "created_at": "timestamp",
    "updated_at": "timestamp",
    "student": {
      "id": "uuid",
      "name": "string",
      "email": "string",
      "nim": "string",
      "department": "string",
      "year": "string"
    },
    "supervisors": [
      {
        "id": "uuid",
        "name": "string",
        "email": "string",
        "nidn": "string",
        "department": "string"
      }
    ],
    "examiners": [
      {
        "id": "uuid",
        "name": "string",
        "email": "string",
        "nidn": "string",
        "department": "string"
      }
    ]
  }
}
```

### Get All Theses

Get all theses.

**Endpoint**: `GET /theses`

**Auth**: Required (Admin/Lecture/Student)

**Response (200)**:

```json
{
  "data": [
    {
      "id": "uuid",
      "title": "string",
      "abstract": "string",
      "research_field": "string",
      "status": "string",
      "student_id": "uuid",
      "created_at": "timestamp",
      "updated_at": "timestamp",
      "student": {
        "id": "uuid",
        "name": "string",
        "nim": "string",
        "email": "string",
        "department": "string",
        "year": "string"
      },
      "supervisors": [
        {
          "id": "uuid",
          "name": "string",
          "email": "string",
          "nidn": "string",
          "department": "string"
        }
      ],
      "examiners": [
        {
          "id": "uuid",
          "name": "string",
          "email": "string",
          "nidn": "string",
          "department": "string"
        }
      ]
    }
  ]
}
```

### Assign Examiner

Assign an examiner to a thesis.

**Endpoint**: `POST /theses/{id}/examiner/{lecture_id}`

**Auth**: Required (Admin)

**Response (200)**:

```json
{
  "message": "examiner assigned successfully"
}
```

### Assign Supervisor

Assign a supervisor to a thesis.

**Endpoint**: `POST /theses/{id}/supervisor/{lecture_id}`

**Auth**: Required (Admin)

**Response (200)**:

```json
{
  "message": "supervisor assigned successfully"
}
```

## Progress Management

### Add Progress

Add a new progress update.

**Endpoint**: `POST /progress`

**Auth**: Required (Student)

**Request Body**:

```json
{
  "thesis_id": "uuid",
  "reviewer_id": "uuid",
  "progress_description": "string",
  "document_url": "string"
}
```

**Response (201)**:

```json
{
	"data": {
		"id": "uuid",
		"thesis_id": "uuid",
		"reviewer_id": "uuid",
		"progress_description": "string",
		"document_url": "string",
		"status": "Pending",
		"achievement_date": "timestamp",
		"created_at": "timestamp",
		"updated_at": "timestamp",
		"reviewer": {
			"id": "uuid",
			"name": "string",
			"nidn": "string",
			"email": "string",
			"department": "string",
			"created_at": "timestamp",
			"updated_at": "timestamp"
		}
	}
}
```

### Get Progress

Get progress details by ID.

**Endpoint**: `GET /progress/{id}`

**Auth**: Required (Admin/Lecture/Student)

**Response (200)**:

```json
{
  "data": {
    "id": "uuid",
    "thesis_id": "uuid",
    "reviewer_id": "uuid",
    "progress_description": "string",
    "document_url": "string",
    "status": "string",
    "achievement_date": "timestamp",
    "created_at": "timestamp",
    "updated_at": "timestamp",
    "reviewer": {
      "id": "uuid",
      "name": "string",
      "nidn": "string",
      "email": "string",
      "department": "string",
      "created_at": "timestamp",
      "updated_at": "timestamp"
    }
  }
}
```

### Get Progresses By Thesis

Get all progresses by thesis ID.

**Endpoint**: `GET /progress/thesis/{thesisId}`

**Auth**: Required (Admin/Lecture/Student)

**Response (200)**:

```json
{
  "data": [
    {
      "id": "uuid",
      "thesis_id": "uuid",
      "reviewer_id": "uuid",
      "progress_description": "string",
      "document_url": "string",
      "status": "string",
      "achievement_date": "timestamp",
      "created_at": "timestamp",
      "updated_at": "timestamp",
      "reviewer": {
        "id": "uuid",
        "name": "string",
        "nidn": "string",
        "email": "string",
        "department": "string",
        "created_at": "timestamp",
        "updated_at": "timestamp"
      }
    }
  ]
}
```

### Update Progress

Update a progress update.

**Endpoint**: `PUT /progress/{id}`

**Auth**: Required (Student)

**Request Body**:

```json
{
  "progress_description": "string",
  "document_url": "string"
}
```

### Review Progress

Review a progress update.

**Endpoint**: `POST /progress/{id}/review`

**Auth**: Required (Lecture)

**Request Body**:

```json
{
  "comment": "string",
  "parent_id": "uuid"
}
```

**Response (200)**:

```json
{
	"data": {
		"comment": {
			"id": "uuid",
			"progress_id": "uuid",
			"user_id": "uuid",
			"user_type": "Lecture",
			"parent_id": "uuid", // null if it's a root comment
			"content": "string",
			"created_at": "timestamp",
			"updated_at": "timestamp",
			"replies": [],
			"user": {
				"id": "uuid",
				"name": "string",
				"nidn": "string",
				"email": "string",
				"department": "string",
				"created_at": "timestamp",
				"updated_at": "timestamp"
			}
		},
		"progress": {
			"id": "uuid",
			"thesis_id": "uuid",
			"reviewer_id": "uuid",
			"progress_description": "string",
			"document_url": "string",
			"status": "Reviewed",
			"achievement_date": "timestamp",
			"created_at": "timestamp",
			"updated_at": "timestamp",
			"reviewer": {
				"id": "uuid",
				"name": "string",
				"nidn": "string",
				"email": "string",
				"department": "string",
				"created_at": "timestamp",
				"updated_at": "timestamp"
			}
		}
	}
}
```

### Get Comments By Progress

Get all comments by progress ID.

**Endpoint**: `GET /progress/{progressId}/comments`

**Auth**: Required (Admin/Lecture/Student)

**Response (200)**:

```json
{
	"data": [
		{
			"id": "uuid",
			"progress_id": "uuid",
			"user_id": "uuid",
			"user_type": "Student/Lecture",
			"parent_id": "uuid",
			"content": "string",
			"created_at": "timestamp",
			"updated_at": "timestamp",
			"replies": [
				{
					"id": "uuid",
					"progress_id": "uuid",
					"user_id": "uuid",
					"user_type": "Student/Lecture",
					"parent_id": "uuid",
					"content": "string",
					"created_at": "timestamp",
					"updated_at": "timestamp",
					"replies": null,
					"user": {
						"id": "uuid",
						"name": "string",
						"nidn": "string",
						"email": "string",
						"department": "string",
						"created_at": "timestamp",
						"updated_at": "timestamp"
					}
				}
			],
			"user": {
				"id": "uuid",
				"name": "string",
				"nidn": "string",
				"email": "string",
				"department": "string",
				"created_at": "timestamp",
				"updated_at": "timestamp"
			}
		}
	]
}
```

### Add Comment

Add a new comment to a progress.

**Endpoint**: `POST /progress/{progressId}/comment`

**Auth**: Required (Student/Lecture)

**Request Body**:

```json
{
  "content": "string",
  "parent_id": "uuid"
}
```

**Response (200)**:

```json
{
	"data": {
		"id": "uuid",
		"progress_id": "uuid",
		"user_id": "uuid",
		"user_type": "Student/Lecture",
		"parent_id": "uuid",
		"content": "string",
		"created_at": "timestamp",
		"updated_at": "timestamp",
		"replies": [],
		"user": {
			"id": "uuid",
			"name": "string",
			"nim": "string",
			"email": "string",
			"department": "string",
			"year": "string",
			"created_at": "timestamp",
			"updated_at": "timestamp"
		}
	}
}
```

## Document Management

### Upload Draft Document

Upload a thesis draft document.

**Endpoint**: `POST /documents/thesis/{thesisId}/draft`

**Auth**: Required (Student)

**Request Body**: multipart/form-data

- document: file (PDF, max 10MB)

**Response (200)**:

```json
{
  "message": "draft document uploaded successfully",
  "url": "string"
}
```

### Upload Final Document

Upload a thesis final document.

**Endpoint**: `POST /documents/thesis/{thesisId}/final`

**Auth**: Required (Student)

**Request Body**: multipart/form-data

- document: file (PDF, max 10MB)

**Response (200)**:

```json
{
  "message": "final document uploaded successfully",
  "url": "string"
}
```

### Upload Progress Document

Upload a progress document.

**Endpoint**: `POST /documents/progress/{progressId}`

**Auth**: Required (Student)

**Request Body**: multipart/form-data

- document: file (PDF, max 10MB)

**Response (200)**:

```json
{
  "message": "progress document uploaded successfully",
  "url": "string"
}
```

## Error Responses

All error responses follow this format:

```json
{
  "error": "error message"
}
```

### Common Error Status Codes

- **400 Bad Request**: Invalid input data
- **401 Unauthorized**: Missing or invalid authentication
- **403 Forbidden**: Insufficient permissions
- **404 Not Found**: Resource not found
- **500 Internal Server Error**: Server error

### Validation Errors

For validation errors, the response includes details about the invalid fields:

```json
{
  "error": "validation failed",
  "details": {
    "field_name": "error message"
  }
}
```
