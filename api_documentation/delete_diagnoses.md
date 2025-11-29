# Endpoint: /api/diagnoses/{diagnosis} (DELETE)

**Method:** `DELETE`

**Description:**
Deletes a nursing diagnosis. Requires 'dosen' role.

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
curl -X DELETE -H "Authorization: Bearer {dosen_token}" -H "Accept: application/json" http://127.0.0.1:8000/api/diagnoses/1
```

**Success Response (200 OK):**
```json
{
  "message": "Nursing diagnosis deleted successfully"
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
