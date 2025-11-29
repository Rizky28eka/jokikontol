# Endpoint: /api/dashboard/mahasiswa (GET)

**Method:** `GET`

**Description:**
Retrieves dashboard statistics for a user with the 'mahasiswa' role.

**Headers:**

| Header        | Value               | Description                               |
|---------------|---------------------|-------------------------------------------|
| `Authorization` | `Bearer {token}`    | **Required.** The user's authentication token (must have 'mahasiswa' role). |
| `Accept`        | `application/json`  | **Required.** Specifies the expected response format. |

**Example Request:**
```bash
curl -X GET -H "Authorization: Bearer {token}" -H "Accept: application/json" http://127.0.0.1:8000/api/dashboard/mahasiswa
```

**Success Response (200 OK):**
Returns dashboard statistics relevant to a 'mahasiswa' user.
```json
{
  "total_forms_created": 5,
  "forms_in_draft": 2,
  "forms_submitted": 2,
  "forms_approved": 1
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
If the authenticated user does not have the 'mahasiswa' role.
```json
{
  "message": "This action is unauthorized."
}
```
