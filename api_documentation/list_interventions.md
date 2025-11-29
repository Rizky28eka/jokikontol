# Endpoint: /api/interventions (GET)

**Method:** `GET`

**Description:**
Retrieves a paginated list of nursing interventions. Requires 'dosen' role.

**Headers:**

| Header        | Value               | Description                               |
|---------------|---------------------|-------------------------------------------|
| `Authorization` | `Bearer {dosen_token}`| **Required.** The user's authentication token (must have 'dosen' role). |
| `Accept`        | `application/json`  | **Required.** Specifies the expected response format. |

**Example Request:**
```bash
curl -X GET -H "Authorization: Bearer {dosen_token}" -H "Accept: application/json" http://127.0.0.1:8000/api/interventions
```

**Success Response (200 OK):**
Returns a paginated list of nursing interventions.
```json
{
  "current_page": 1,
  "data": [
    {
      "id": 1,
      "code": "I.0101",
      "name": "Manajemen Jalan Napas",
      "diagnosis_id": 1,
      "created_at": "2025-11-29T00:00:00.000000Z",
      "updated_at": "2025-11-29T00:00:00.000000Z"
    }
  ],
  "first_page_url": "http://127.0.0.1:8000/api/interventions?page=1",
  "from": 1,
  "last_page": 1,
  "last_page_url": "http://127.0.0.1:8000/api/interventions?page=1",
  "links": [],
  "next_page_url": null,
  "path": "http://127.0.0.1:8000/api/interventions",
  "per_page": 10,
  "prev_page_url": null,
  "to": 1,
  "total": 1
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
