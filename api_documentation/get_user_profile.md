# Endpoint: /api/user/profile (GET)

**Method:** `GET`

**Description:**
Retrieves the profile information of the currently authenticated user.

**Headers:**

| Header        | Value               | Description                               |
|---------------|---------------------|-------------------------------------------|
| `Authorization` | `Bearer {token}`    | **Required.** The user's authentication token. |
| `Accept`        | `application/json`  | **Required.** Specifies the expected response format. |

**Example Request:**
```bash
curl -X GET -H "Authorization: Bearer {token}" -H "Accept: application/json" http://127.0.0.1:8000/api/user/profile
```

**Success Response (200 OK):**
Returns the user's profile information.
```json
{
  "id": 1,
  "name": "Test User",
  "email": "test@example.com",
  "role": "mahasiswa"
}
```

**Error Response (401 Unauthorized):**
If the token is invalid or not provided.
```json
{
  "message": "Unauthenticated."
}
```
