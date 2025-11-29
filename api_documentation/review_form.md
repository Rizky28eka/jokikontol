# Endpoint: /api/forms/{form}/review (POST)

**Method:** `POST`

**Description:**
Reviews a specific form, typically changing its status. Accessible by users with 'dosen' role.

**Headers:**

| Header        | Value               | Description                               |
|---------------|---------------------|-------------------------------------------|
| `Authorization` | `Bearer {dosen_token}`| **Required.** The user's authentication token (must have 'dosen' role). |
| `Content-Type`  | `application/json`| **Required.** Specifies the content type of the request body. |
| `Accept`        | `application/json`  | **Required.** Specifies the expected response format. |

**URL Parameters:**

| Parameter | Type    | Description              |
|-----------|---------|--------------------------|
| `form`    | integer | **Required.** The ID of the form to review. |

**Request Body:**

| Field      | Type     | Description                  |
|------------|----------|------------------------------|
| `status`   | `string` | **Required.** The new status for the form. Allowed values: `submitted`, `revised`, `approved`. |
| `notes`    | `string` | Optional notes from the reviewer. |

**Example Request:**
```json
{
  "status": "approved",
  "notes": "Form looks good."
}
```

**Success Response (200 OK):**
Returns a success message and the updated form data.
```json
{
  "message": "Form reviewed successfully",
  "form": {
    "id": 1,
    "type": "pengkajian",
    "user_id": 1,
    "patient_id": 2,
    "status": "approved",
    "data": {
      "symptoms": "headache",
      "notes": "patient feels dizzy"
    },
    "reviewer_notes": "Form looks good.",
    "created_at": "2025-11-29T00:03:26.000000Z",
    "updated_at": "2025-11-29T00:05:00.000000Z"
  }
}
```

**Error Response (422 Unprocessable Entity):**
If validation fails.
```json
{
    "message": "The given data was invalid.",
    "errors": {
        "status": [
            "The selected status is invalid."
        ]
    }
}
```

**Error Response (403 Forbidden):**
If the authenticated user does not have the 'dosen' role.
```json
{
  "message": "Unauthorized"
}
```

**Error Response (404 Not Found):**
If the form with the specified ID does not exist.

**Error Response (401 Unauthorized):**
If the token is invalid or not provided.
```json
{
  "message": "Unauthenticated."
}
```
