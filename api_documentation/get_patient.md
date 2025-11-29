# Endpoint: /api/patients/{patient} (GET)

**Method:** `GET`

**Description:**
Retrieves a single patient by their ID. The authenticated user must be the creator of the patient record.

**Headers:**

| Header        | Value               | Description                               |
|---------------|---------------------|-------------------------------------------|
| `Authorization` | `Bearer {token}`    | **Required.** The user's authentication token. |
| `Accept`        | `application/json`  | **Required.** Specifies the expected response format. |

**URL Parameters:**

| Parameter | Type    | Description              |
|-----------|---------|--------------------------|
| `patient` | integer | **Required.** The ID of the patient. |

**Example Request:**
```bash
curl -X GET -H "Authorization: Bearer {token}" -H "Accept: application/json" http://127.0.0.1:8000/api/patients/1
```

**Success Response (200 OK):**
Returns the patient's data.
```json
{
  "id": 1,
  "name": "John Doe",
  "gender": "L",
  "age": 30,
  "address": "123 Main St",
  "rm_number": "RM001",
  "created_by": 1,
  "created_at": "2025-11-29T00:00:31.000000Z",
  "updated_at": "2025-11-29T00:00:31.000000Z"
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
