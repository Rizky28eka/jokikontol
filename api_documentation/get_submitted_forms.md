# Endpoint: /api/forms/submitted (GET)

**Method:** `GET`

**Description:**
Retrieves a paginated list of forms that have been submitted (status 'submitted' or 'approved'). Accessible by users with 'dosen' role.

**Headers:**

| Header        | Value               | Description                               |
|---------------|---------------------|-------------------------------------------|
| `Authorization` | `Bearer {dosen_token}`| **Required.** The user's authentication token (must have 'dosen' role). |
| `Accept`        | `application/json`  | **Required.** Specifies the expected response format. |

**Example Request:**
```bash
curl -X GET -H "Authorization: Bearer {dosen_token}" -H "Accept: application/json" http://127.0.0.1:8000/api/forms/submitted
```

**Success Response (200 OK):**
Returns a paginated list of submitted/approved forms.
```json
{
  "current_page": 1,
  "data": [
    {
      "id": 1,
      "type": "pengkajian",
      "user_id": 1,
      "patient_id": 2,
      "status": "submitted",
      "data": {
        "symptoms": "headache",
        "notes": "patient feels dizzy"
      },
      "created_at": "2025-11-29T00:03:26.000000Z",
      "updated_at": "2025-11-29T00:03:26.000000Z"
    }
  ],
  "first_page_url": "http://127.0.0.1:8000/api/forms/submitted?page=1",
  "from": 1,
  "last_page": 1,
  "last_page_url": "http://127.0.0.1:8000/api/forms/submitted?page=1",
  "links": [],
  "next_page_url": null,
  "path": "http://127.0.0.1:8000/api/forms/submitted",
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
