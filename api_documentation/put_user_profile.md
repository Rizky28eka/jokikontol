# Endpoint: /api/user/profile (PUT)

**Method:** `PUT`

**Description:**
Updates the profile information of the currently authenticated user.

**Headers:**

| Header        | Value               | Description                               |
|---------------|---------------------|-------------------------------------------|
| `Authorization` | `Bearer {token}`    | **Required.** The user's authentication token. |
| `Content-Type`  | `application/json`| **Required.** Specifies the content type of the request body. |
| `Accept`        | `application/json`  | **Required.** Specifies the expected response format. |

**Request Body:**

| Field      | Type     | Description                  |
|------------|----------|------------------------------|
| `name`     | `string` | The new name for the user. |
| `password` | `string` | The new password for the user. |
| `password_confirmation` | `string` | The confirmation of the new password. |

**Example Request:**
```json
{
  "name": "New Name"
}
```

**Success Response (200 OK):**
Returns a success message and the updated user information.
```json
{
  "message": "Profile updated successfully",
  "user": {
    "id": 1,
    "name": "New Name",
    "email": "test@example.com",
    "role": "mahasiswa"
  }
}
```

**Error Response (422 Unprocessable Entity):**
If the validation fails.
```json
{
    "message": "The given data was invalid.",
    "errors": {
        "password": [
            "The password confirmation does not match."
        ]
    }
}
```

**Error Response (401 Unauthorized):**
If the token is invalid or not provided.
```json
{
  "message": "Unauthenticated."
}
```
