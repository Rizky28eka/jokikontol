# Endpoint: /api/diagnoses/{diagnosis} (GET)

**Method:** `GET`

**Description:**
Retrieves a single nursing diagnosis by its ID. Requires 'dosen' role.

**Headers:**

| Header        | Value               | Description                               |
|---------------|---------------------|-------------------------------------------|
| `Authorization` | `Bearer {dosen_token}`| **Required.** The user's authentication token (must have 'dosen' role). |
| `Accept`        | `application/json`  | **Required.** Specifies the expected response format. |

**URL Parameters:**

| Parameter | Type    | Description                      |
|-----------|---------|----------------------------------|
| `diagnosis` | integer | **Required.** The ID of the nursing diagnosis. |

**Example Request:**
```bash
curl -X GET -H "Authorization: Bearer {dosen_token}" -H "Accept: application/json" http://127.0.0.1:8000/api/diagnoses/1
```

**Success Response (200 OK):**
Returns the nursing diagnosis data.
```json
{
  "id": 1,
  "code": "D.0001",
  "name": "Bersihan Jalan Napas Tidak Efektif",
  "created_at": "2025-11-29T00:00:00.000000Z",
  "updated_at": "2025-11-29T00:00:00.000000Z"
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
