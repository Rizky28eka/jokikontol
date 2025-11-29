# Endpoint: /api/forms/{form} (PUT/PATCH)

**Method:** `PUT` or `PATCH`

**Description:**
Updates a form's information. The authenticated user must be the creator of the form.

**Headers:**

| Header        | Value               | Description                               |
|---------------|---------------------|-------------------------------------------|
| `Authorization` | `Bearer {token}`    | **Required.** The user's authentication token. |
| `Content-Type`  | `application/json`  | **Required.** Specifies the content type of the request body. |
| `Accept`        | `application/json`  | **Required.** Specifies the expected response format. |

**URL Parameters:**

| Parameter | Type    | Description              |
|-----------|---------|--------------------------|
| `form`    | integer | **Required.** The ID of the form. |

**Request Body:**

| Field      | Type     | Description                  |
|------------|----------|------------------------------|
| `type`     | `string` | The type of the form. Allowed values: `pengkajian`, `resume_kegawatdaruratan`, `resume_poliklinik`, `sap`, `catatan_tambahan`. |
| `patient_id`| `integer`| The ID of the patient this form belongs to. |
| `data`     | `array`  | An array of data associated with the form. |
| `status`   | `string` | The status of the form. Allowed values: `draft`, `submitted`, `revised`, `approved`. |

**Example Request:**
```json
{
  "data": {
    "symptoms": "fever",
    "notes": "patient has a high temperature"
  }
}
```

**Success Response (200 OK):**
Returns a success message and the updated form data.
```json
{
  "message": "Form updated successfully",
  "form": {
    "id": 1,
    "type": "pengkajian",
    "user_id": 1,
    "patient_id": 2,
    "status": "draft",
    "data": {
      "symptoms": "fever",
      "notes": "patient has a high temperature"
    },
    "created_at": "2025-11-29T00:03:26.000000Z",
    "updated_at": "2025-11-29T00:04:40.000000Z",
    "genogram": null
  }
}
```

**Error Response (422 Unprocessable Entity):**
If validation fails.
```json
{
    "message": "The given data was invalid.",
    "errors": {
        "type": [
            "The selected type is invalid."
        ]
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
