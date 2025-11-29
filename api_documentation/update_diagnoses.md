# Endpoint: /api/diagnoses/{diagnosis} (PUT/PATCH)

**Method:** `PUT` or `PATCH`

**Description:**
Updates a nursing diagnosis. Requires 'dosen' role.

**Headers:**

| Header        | Value               | Description                               |
|---------------|---------------------|-------------------------------------------|
| `Authorization` | `Bearer {dosen_token}`| **Required.** The user's authentication token (must have 'dosen' role). |
| `Content-Type`  | `application/json`  | **Required.** Specifies the content type of the request body. |
| `Accept`        | `application/json`  | **Required.** Specifies the expected response format. |

**URL Parameters:**

| Parameter | Type    | Description                      |
|-----------|---------|----------------------------------|
| `diagnosis` | integer | **Required.** The ID of the nursing diagnosis. |

**Request Body:**

| Field      | Type     | Description                  |
|------------|----------|------------------------------|
| `code`     | `string` | The unique code for the diagnosis. |
| `name`     | `string` | The name of the diagnosis. |

**Example Request:**
```json
{
  "name": "Bersihan Jalan Napas Tidak Efektif (Revisi)"
}
```

**Success Response (200 OK):**
Returns a success message and the updated nursing diagnosis data.
```json
{
  "message": "Nursing diagnosis updated successfully",
  "diagnosis": {
    "id": 1,
    "code": "D.0001",
    "name": "Bersihan Jalan Napas Tidak Efektif (Revisi)",
    "created_at": "2025-11-29T00:00:00.000000Z",
    "updated_at": "2025-11-29T00:00:00.000000Z"
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

**Error Response (403 Forbidden):**
If the authenticated user does not have the 'dosen' role.
```json
{
  "message": "This action is unauthorized."
}
```

**Error Response (404 Not Found):**
If the nursing diagnosis with the specified ID does not exist.

**Error Response (401 Unauthorized):**
If the token is invalid or not provided.
```json
{
  "message": "Unauthenticated."
}
```
