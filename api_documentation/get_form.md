# Endpoint: /api/forms/{form} (GET)

**Method:** `GET`

**Description:**
Retrieves a single form by its ID. The authenticated user must be the creator of the form.

**Headers:**

| Header        | Value               | Description                               |
|---------------|---------------------|-------------------------------------------|
| `Authorization` | `Bearer {token}`    | **Required.** The user's authentication token. |
| `Accept`        | `application/json`  | **Required.** Specifies the expected response format. |

**URL Parameters:**

| Parameter | Type    | Description              |
|-----------|---------|--------------------------|
| `form`    | integer | **Required.** The ID of the form. |

**Example Request:**
```bash
curl -X GET -H "Authorization: Bearer {token}" -H "Accept: application/json" http://127.0.0.1:8000/api/forms/1
```

**Success Response (200 OK):**
Returns the form data.
```json
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
  "updated_at": "2025-11-29T00:03:26.000000Z",
  "genogram": null
}
```

You can also request a simple SVG preview for the form's genogram using:

```bash
curl -X GET -H "Authorization: Bearer {token}" -H "Accept: image/svg+xml" http://127.0.0.1:8000/api/forms/1/genogram/svg
```

If a genogram is present, it will be included like the following:

```json
{
  "id": 1,
  "type": "pengkajian",
  "user_id": 1,
  "patient_id": 2,
  "status": "draft",
  "data": { /* form data */ },
  "created_at": "2025-11-29T00:03:26.000000Z",
  "updated_at": "2025-11-29T00:03:26.000000Z",
  "genogram": {
    "id": 1,
    "form_id": 1,
    "structure": {
      "members": [ /* array */ ],
      "connections": [ /* array */ ]
    },
    "notes": "Pola komunikasi rapuh antara orang tua"
  }
}
```

**Error Response (403 Forbidden):**
If the authenticated user is not the creator of the form.
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
