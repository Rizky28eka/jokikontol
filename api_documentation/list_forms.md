# Endpoint: /api/forms (GET)

**Method:** `GET`

**Description:**
Retrieves a paginated list of forms created by the authenticated user. Can be filtered by `type` and `patient_id`.

**Headers:**

| Header        | Value               | Description                               |
|---------------|---------------------|-------------------------------------------|
| `Authorization` | `Bearer {token}`    | **Required.** The user's authentication token. |
| `Accept`        | `application/json`  | **Required.** Specifies the expected response format. |

**Query Parameters:**

| Parameter  | Type    | Description                               |
|------------|---------|-------------------------------------------|
| `type`     | string  | Filter forms by type.                     |
| `patient_id`| integer | Filter forms by patient ID.               |

**Example Request:**
```bash
curl -X GET -H "Authorization: Bearer {token}" -H "Accept: application/json" "http://127.0.0.1:8000/api/forms"
```

**Success Response (200 OK):**
Returns a paginated list of forms.
```json
{
  "current_page": 1,
  "data": [
    {
      "id": 1,
      "type": "pengkajian",
      "user_id": 1,
      "patient_id": 2,
      "status": "draft",
      "data": {
        "symptoms": "headache",
        "notes": "patient feels dizzy"
      },
      "created_at": "2025-11-29T00:03:26.000000Z",
      "updated_at": "2025-11-29T00:03:26.000000Z"
    }
  ],
  "first_page_url": "http://127.0.0.1:8000/api/forms?page=1",
  "from": 1,
  "last_page": 1,
  "last_page_url": "http://127.0.0.1:8000/api/forms?page=1",
  "links": [
    {
      "url": null,
      "label": "&laquo; Previous",
      "page": null,
      "active": false
    },
    {
      "url": "http://127.0.0.1:8000/api/forms?page=1",
      "label": "1",
      "page": 1,
      "active": true
    },
    {
      "url": null,
      "label": "Next &raquo;",
      "page": null,
      "active": false
    }
  ],
  "next_page_url": null,
  "path": "http://127.0.0.1:8000/api/forms",
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
