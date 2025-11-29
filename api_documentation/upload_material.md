# Endpoint: /api/forms/{form}/upload-material (POST)

**Method:** `POST`

**Description:**
Uploads a material file for a specific form. The authenticated user must be the creator of the form.

**Headers:**

| Header        | Value               | Description                               |
|---------------|---------------------|-------------------------------------------|
| `Authorization` | `Bearer {token}`    | **Required.** The user's authentication token. |
| `Content-Type`  | `multipart/form-data`| **Required.** Specifies the content type of the request body for file uploads. |
| `Accept`        | `application/json`  | **Required.** Specifies the expected response format. |

**URL Parameters:**

| Parameter | Type    | Description              |
|-----------|---------|--------------------------|
| `form`    | integer | **Required.** The ID of the form. |

**Request Body (multipart/form-data):**

| Field      | Type     | Description                  |
|------------|----------|------------------------------|
| `material` | `file`   | **Required.** The material file to upload. |

**Example Request:**
```bash
curl -X POST -H "Authorization: Bearer {token}" -H "Accept: application/json" -F "material=@/path/to/your/file.pdf" http://127.0.0.1:8000/api/forms/1/upload-material
```

**Success Response (200 OK):**
Returns a success message and the URL of the uploaded material.
```json
{
  "message": "Material uploaded successfully",
  "url": "http://127.0.0.1:8000/storage/materials/form_1_material_1678886400.pdf"
}
```

**Error Response (422 Unprocessable Entity):**
If validation fails (e.g., no file provided, invalid file type).
```json
{
    "message": "The given data was invalid.",
    "errors": {
        "material": [
            "The material field is required."
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
