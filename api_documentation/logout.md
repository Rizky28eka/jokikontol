# Endpoint: /api/logout

**Method:** `POST`

**Description:**
Logs out the current authenticated user by revoking their session token.

**Headers:**

| Header        | Value               | Description                               |
|---------------|---------------------|-------------------------------------------|
| `Authorization` | `Bearer {token}`    | **Required.** The user's authentication token. |
| `Accept`        | `application/json`  | **Required.** Specifies the expected response format. |

**Example Request:**
```bash
curl -X POST -H "Authorization: Bearer {token}" -H "Accept: application/json" http://127.0.0.1:8000/api/logout
```

**Success Response (200 OK):**
```json
{
  "message": "Successfully logged out"
}
```

**Error Response (401 Unauthorized):**
If the token is invalid or not provided.
```json
{
  "message": "Unauthenticated."
}
```
