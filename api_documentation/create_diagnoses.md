# Endpoint: /api/diagnoses (POST)

**Method:** `POST`

**Description:**
Creates a new nursing diagnosis. Requires 'dosen' role.

**Headers:**

| Header        | Value               | Description                               |
|---------------|---------------------|-------------------------------------------|
| `Authorization` | `Bearer {dosen_token}`| **Required.** The user's authentication token (must have 'dosen' role). |
| `Content-Type`  | `application/json`| **Required.** Specifies the content type of the request body. |
| `Accept`        | `application/json`  | **Required.** Specifies the expected response format. |

**Request Body:**

| Field      | Type     | Description                  |
|------------|----------|------------------------------|
| `code`     | `string` | **Required.** The unique code for the diagnosis. |
| `name`     | `string` | **Required.** The name of the diagnosis. |

**Example Request:**
```json
{
  "code": "D.0001",
  "name": "Bersihan Jalan Napas Tidak Efektif"
}
```

**Success Response (201 Created):**
Returns a success message and the newly created nursing diagnosis data.
```json
{
  "message": "Nursing diagnosis created successfully",
  "diagnosis": {
    "code": "D.0001",
    "name": "Bersihan Jalan Napas Tidak Efektif",
    "updated_at": "2025-11-29T00:00:00.000000Z",
    "created_at": "2025-11-29T00:00:00.000000Z",
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
        "code": [
            "The code field is required."
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

**Error Response (403 Forbidden):**
If the authenticated user does not have the 'dosen' role.
```json
{
  "message": "This action is unauthorized."
}
```
