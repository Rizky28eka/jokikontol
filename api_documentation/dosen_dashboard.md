# Endpoint: /api/dashboard/dosen (GET)

**Method:** `GET`

**Description:**
Retrieves dashboard statistics for a user with the 'dosen' role.

**Headers:**

| Header        | Value               | Description                               |
|---------------|---------------------|-------------------------------------------|
| `Authorization` | `Bearer {dosen_token}`| **Required.** The user's authentication token (must have 'dosen' role). |
| `Accept`        | `application/json`  | **Required.** Specifies the expected response format. |

**Example Request:**
```bash
curl -X GET -H "Authorization: Bearer {dosen_token}" -H "Accept: application/json" http://127.0.0.1:8000/api/dashboard/dosen
```

**Success Response (200 OK):**
Returns dashboard statistics relevant to a 'dosen' user.
```json
{
  "total_forms_submitted": 10,
  "forms_pending_review": 3,
  "forms_approved": 7,
  "total_patients": 20
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
