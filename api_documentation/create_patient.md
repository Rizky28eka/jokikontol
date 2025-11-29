# Endpoint: /api/patients (POST)

**Method:** `POST`

**Description:**
Creates a new patient record.

**Headers:**

| Header        | Value               | Description                               |
|---------------|---------------------|-------------------------------------------|
| `Authorization` | `Bearer {token}`    | **Required.** The user's authentication token. |
| `Content-Type`  | `application/json`| **Required.** Specifies the content type of the request body. |
| `Accept`        | `application/json`  | **Required.** Specifies the expected response format. |

**Request Body:**

| Field      | Type     | Description                  |
|------------|----------|------------------------------|
| `name`     | `string` | **Required.** The patient's name. |
| `gender`   | `string` | **Required.** The patient's gender (`L` for male, `P` for female). |
| `age`      | `integer`| **Required.** The patient's age. |
| `address`  | `string` | **Required.** The patient's address. |
| `rm_number`| `string` | **Required.** The patient's medical record number (must be unique). |

**Example Request:**
```json
{
  "name": "John Doe",
  "gender": "L",
  "age": 30,
  "address": "123 Main St",
  "rm_number": "RM001"
}
```

**Success Response (201 Created):**
Returns a success message and the newly created patient data.
```json
{
  "message": "Patient created successfully",
  "patient": {
    "name": "John Doe",
    "gender": "L",
    "age": 30,
    "address": "123 Main St",
    "rm_number": "RM001",
    "created_by": 1,
    "updated_at": "2025-11-29T00:00:31.000000Z",
    "created_at": "2025-11-29T00:00:31.000000Z",
    "id": 1
  }
}
```

**Error Response (422 Unprocessable Entity):**
If validation fails.
```json
{
    "message": "The given data was invalid.",
    "errors": {
        "name": [
            "The name field is required."
        ]
    }
}
```

**Error Response (401 Unauthorized):**
If the token is invalid or not provided.
```json
{
  "message": "Unauthenticated."
}
```
