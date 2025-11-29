# Endpoint: /api/patients/{patient} (PUT/PATCH)

**Method:** `PUT` or `PATCH`

**Description:**
Updates a patient's information. The authenticated user must be the creator of the patient record.

**Headers:**

| Header        | Value               | Description                               |
|---------------|---------------------|-------------------------------------------|
| `Authorization` | `Bearer {token}`    | **Required.** The user's authentication token. |
| `Content-Type`  | `application/json`  | **Required.** Specifies the content type of the request body. |
| `Accept`        | `application/json`  | **Required.** Specifies the expected response format. |

**URL Parameters:**

| Parameter | Type    | Description              |
|-----------|---------|--------------------------|
| `patient` | integer | **Required.** The ID of the patient. |

**Request Body:**

| Field      | Type     | Description                  |
|------------|----------|------------------------------|
| `name`     | `string` | The patient's name. |
| `gender`   | `string` | The patient's gender (`L` for male, `P` for female). |
| `age`      | `integer`| The patient's age. |
| `address`  | `string` | The patient's address. |
| `rm_number`| `string` | The patient's medical record number (must be unique). |

**Example Request:**
```json
{
  "name": "Jane Doe"
}
```

**Success Response (200 OK):**
Returns a success message and the updated patient data.
```json
{
  "message": "Patient updated successfully",
  "patient": {
    "id": 1,
    "name": "Jane Doe",
    "gender": "L",
    "age": 30,
    "address": "123 Main St",
    "rm_number": "RM001",
    "created_by": 1,
    "created_at": "2025-11-29T00:00:31.000000Z",
    "updated_at": "2025-11-29T00:01:53.000000Z"
  }
}
```

**Error Response (422 Unprocessable Entity):**
If validation fails.
```json
{
    "message": "The given data was invalid.",
    "errors": {
        "age": [
            "The age must be an integer."
        ]
    }
}
```

**Error Response (403 Forbidden):**
If the authenticated user is not the creator of the patient record.
```json
{
  "message": "Unauthorized"
}
```

**Error Response (404 Not Found):**
If the patient with the specified ID does not exist.

**Error Response (401 Unauthorized):**
If the token is invalid or not provided.
```json
{
  "message": "Unauthenticated."
}
```
