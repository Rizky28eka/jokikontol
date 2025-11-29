# Endpoint: /api/interventions (POST)

**Method:** `POST`

**Description:**
Creates a new nursing intervention. Requires 'dosen' role.

**Headers:**

| Header        | Value               | Description                               |
|---------------|---------------------|-------------------------------------------|
| `Authorization` | `Bearer {dosen_token}`| **Required.** The user's authentication token (must have 'dosen' role). |
| `Content-Type`  | `application/json`| **Required.** Specifies the content type of the request body. |
| `Accept`        | `application/json`  | **Required.** Specifies the expected response format. |

**Request Body:**

| Field      | Type     | Description                  |
|------------|----------|------------------------------|
| `code`     | `string` | **Required.** The unique code for the intervention. |
| `name`     | `string` | **Required.** The name of the intervention. |
| `diagnosis_id`| `integer`| **Required.** The ID of the nursing diagnosis this intervention belongs to. |

**Example Request:**
```json
{
  "code": "I.0101",
  "name": "Manajemen Jalan Napas",
  "diagnosis_id": 1
}
```

**Success Response (201 Created):**
Returns a success message and the newly created nursing intervention data.
```json
{
  "message": "Nursing intervention created successfully",
  "intervention": {
    "code": "I.0101",
    "name": "Manajemen Jalan Napas",
    "diagnosis_id": 1,
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
