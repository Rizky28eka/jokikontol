# Endpoint: /api/interventions/{intervention} (GET)

**Method:** `GET`

**Description:**
Retrieves a single nursing intervention by its ID. Requires 'dosen' role.

**Headers:**

| Header        | Value               | Description                               |
|---------------|---------------------|-------------------------------------------|
| `Authorization` | `Bearer {dosen_token}`| **Required.** The user's authentication token (must have 'dosen' role). |
| `Accept`        | `application/json`  | **Required.** Specifies the expected response format. |

**URL Parameters:**

| Parameter | Type    | Description                      |
|-----------|---------|----------------------------------|
| `intervention` | integer | **Required.** The ID of the nursing intervention. |

**Example Request:**
```bash
curl -X GET -H "Authorization: Bearer {dosen_token}" -H "Accept: application/json" http://127.0.0.1:8000/api/interventions/1
```

**Success Response (200 OK):**
Returns the nursing intervention data.
```json
{
  "id": 1,
  "code": "I.0101",
  "name": "Manajemen Jalan Napas",
  "diagnosis_id": 1,
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
If the nursing intervention with the specified ID does not exist.

**Error Response (401 Unauthorized):**
If the token is invalid or not provided.
```json
{
  "message": "Unauthenticated."
}
```
