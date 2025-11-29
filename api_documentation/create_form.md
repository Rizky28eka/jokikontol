# Endpoint: /api/forms (POST)

**Method:** `POST`

**Description:**
Creates a new form.

**Headers:**

| Header        | Value               | Description                               |
|---------------|---------------------|-------------------------------------------|
| `Authorization` | `Bearer {token}`    | **Required.** The user's authentication token. |
| `Content-Type`  | `application/json`| **Required.** Specifies the content type of the request body. |
| `Accept`        | `application/json`  | **Required.** Specifies the expected response format. |

**Request Body:**

| Field      | Type     | Description                  |
|------------|----------|------------------------------|
| `type`     | `string` | **Required.** The type of the form. Allowed values: `pengkajian`, `resume_kegawatdaruratan`, `resume_poliklinik`, `sap`, `catatan_tambahan`. |
| `patient_id`| `integer`| **Required.** The ID of the patient this form belongs to. |
| `data`     | `array`  | An array of data associated with the form. |
| `status`   | `string` | The status of the form. Allowed values: `draft`, `submitted`, `revised`, `approved`. Defaults to `draft`. |

**Example Request:**
```json
{
  "type": "pengkajian",
  "patient_id": 2,
  "data": {
    "symptoms": "headache",
    "notes": "patient feels dizzy"
  }
}
```

**Success Response (201 Created):**
Returns a success message and the newly created form data.
```json
{
  "message": "Form created successfully",
  "form": {
    "type": "pengkajian",
    "patient_id": 2,
    "data": {
      "symptoms": "headache",
      "notes": "patient feels dizzy"
    },
    "user_id": 1,
    "status": "draft",
    "updated_at": "2025-11-29T00:03:26.000000Z",
    "created_at": "2025-11-29T00:03:26.000000Z",
    "id": 1,
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
            "The type field is required."
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
