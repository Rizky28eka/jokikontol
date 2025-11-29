# Endpoint: /api/patients/{patient} (DELETE)

**Method:** `DELETE`

**Description:**
Deletes a patient record. The authenticated user must be the creator of the patient record.

**Headers:**

| Header        | Value               | Description                               |
|---------------|---------------------|-------------------------------------------|
| `Authorization` | `Bearer {token}`    | **Required.** The user's authentication token. |
| `Accept`        | `application/json`  | **Required.** Specifies the expected response format. |

**URL Parameters:**

| Parameter | Type    | Description              |
|-----------|---------|--------------------------|
| `patient` | integer | **Required.** The ID of the patient. |

**Example Request:**
```bash
curl -X DELETE -H "Authorization: Bearer {token}" -H "Accept: application/json" http://127.0.0.1:8000/api/patients/1
```

**Success Response (200 OK):**
```json
{
  "message": "Patient deleted successfully"
}
```

**Error Response (403 Forbidden):**
If the authenticated user is not the creator of the patient record.
```json
{
  "message": "Unauthorized"
}
```

**Error Response (404 Not Found):**
If the patient with the specified ID does not exist.

**Error Response (401 Unauthorized):**
If the token is invalid or not provided.
```json
{
  "message": "Unauthenticated."
}
```
