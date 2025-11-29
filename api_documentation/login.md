# Endpoint: /api/login

**Method:** `POST`

**Description:**
Authenticates a user and returns a session token.

**Request Body:**

| Field      | Type     | Description                  |
|------------|----------|------------------------------|
| `email`    | `string` | **Required.** The user's email address. |
| `password` | `string` | **Required.** The user's password.   |

**Example Request:**
```json
{
  "email": "test@example.com",
  "password": "password"
}
```

**Success Response (200 OK):**
Returns the user's details and an API token.

```json
{
    "user": {
        "id": 1,
        "name": "Test User",
        "email": "test@example.com",
        "role": "mahasiswa"
    },
    "token": "1|zTrpb2g6Cm1oq5z4Uw548iNDucHpr9FS9jgUtIL97e5336fb",
    "token_type": "Bearer"
}
```

**Error Response (422 Unprocessable Entity):**
If the provided credentials are incorrect.
```json
{
    "message": "The provided credentials are incorrect. (and 2 more errors)",
    "errors": {
        "email": [
            "The provided credentials are incorrect."
        ]
    }
}
```
