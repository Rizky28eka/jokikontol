<?php

namespace App\Http\Controllers;

use App\Models\Form;
use App\Models\NursingDiagnosis;
use App\Models\NursingIntervention;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class FormController extends Controller
{
    /**
     * Display a listing of the forms.
     */
    public function index(Request $request)
    {
        $query = Form::query();

        // Filter by authenticated user
        $query->where('user_id', $request->user()->id);

        // Filter by type if provided
        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        // Filter by patient_id if provided
        if ($request->has('patient_id')) {
            $query->where('patient_id', $request->patient_id);
        }

        $forms = $query->with(['genogram', 'patient', 'formable'])->orderBy('created_at', 'desc')->paginate(10);

        return response()->json($forms);
    }

    /**
     * Store a newly created form in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'type' => 'required|string|in:pengkajian,resume_kegawatdaruratan,resume_poliklinik,sap,catatan_tambahan',
            'patient_id' => 'required|exists:patients,id',
            'data' => 'nullable|array',
            'status' => 'sometimes|in:draft,submitted,revised,approved',
        ]);

        $validated['user_id'] = $request->user()->id;
        $validated['status'] = $validated['status'] ?? 'draft';

        // Validate nursing ids found in the data payload
        if (isset($validated['data']) && is_array($validated['data'])) {
            $this->validateNursingIds($validated['data']);
        }

        // Create specific form model based on type
        $formable = $this->createSpecificForm($validated['type'], $validated, $request->all());

        // Create main form with polymorphic reference
        $validated['formable_type'] = get_class($formable);
        $validated['formable_id'] = $formable->id;
        
        $form = Form::create($validated);

        // If the form type is pengkajian and it includes genogram data, validate and create the genogram
        if ($validated['type'] === 'pengkajian' && isset($validated['data']['genogram'])) {
            $genogram = $validated['data']['genogram'];
            // Validate structure before creating
            if (!$this->validateGenogramStructure($genogram['structure'] ?? null)) {
                return response()->json(['message' => 'Invalid genogram structure provided'], 422);
            }
            $form->genogram()->create([
                'structure' => $genogram['structure'] ?? null,
                'notes' => $genogram['notes'] ?? null,
            ]);
        }

        return response()->json([
            'message' => 'Form created successfully',
            'form' => $form->load(['genogram', 'formable'])
        ], 201);
    }

    /**
     * Display the specified form.
     */
    public function show(Request $request, Form $form)
    {
        // Ensure the form belongs to the authenticated user or allow 'dosen' to view submitted forms for review
        if ($form->user_id !== $request->user()->id && $request->user()->role !== 'dosen') {
            return response()->json([
                'error' => [
                    'code' => 'ROLE_FORBIDDEN',
                    'message' => 'You are not authorized to view this form',
                    'required_role' => 'owner_or_dosen'
                ]
            ], 403);
        }

        return response()->json($form->load(['genogram', 'formable']));
    }

    /**
     * Update the specified form in storage.
     */
    public function update(Request $request, Form $form)
    {
        // Ensure the form belongs to the authenticated user
        if ($form->user_id !== $request->user()->id) {
            return response()->json([
                'error' => [
                    'code' => 'ROLE_FORBIDDEN',
                    'message' => 'You are not authorized to update this form',
                    'required_role' => 'owner'
                ]
            ], 403);
        }

        $validated = $request->validate([
            'type' => 'sometimes|required|string|in:pengkajian,resume_kegawatdaruratan,resume_poliklinik,sap,catatan_tambahan',
            'patient_id' => 'sometimes|required|exists:patients,id',
            'data' => 'nullable|array',
            'status' => 'sometimes|in:draft,submitted,revised,approved',
        ]);

        if (isset($validated['data']) && is_array($validated['data'])) {
            $this->validateNursingIds($validated['data']);
        }

        $form->update($validated);

        // If the form type is pengkajian and it includes genogram data, update or create the genogram
        if (($validated['type'] ?? $form->type) === 'pengkajian' && isset($validated['data']['genogram'])) {
            $genogram = $validated['data']['genogram'];
            if (!$this->validateGenogramStructure($genogram['structure'] ?? null)) {
                return response()->json(['message' => 'Invalid genogram structure provided'], 422);
            }
            if ($form->genogram) {
                $form->genogram()->update([
                    'structure' => $genogram['structure'] ?? null,
                    'notes' => $genogram['notes'] ?? null,
                ]);
            } else {
                $form->genogram()->create([
                    'structure' => $genogram['structure'] ?? null,
                    'notes' => $genogram['notes'] ?? null,
                ]);
            }
        }

        return response()->json([
            'message' => 'Form updated successfully',
            'form' => $form->load(['genogram', 'formable'])
        ]);
    }

    /**
     * Remove the specified form from storage.
     */
    public function destroy(Request $request, Form $form)
    {
        // Ensure the form belongs to the authenticated user
        if ($form->user_id !== $request->user()->id) {
            return response()->json([
                'error' => [
                    'code' => 'ROLE_FORBIDDEN',
                    'message' => 'You are not authorized to delete this form',
                    'required_role' => 'owner'
                ]
            ], 403);
        }

        $form->delete();

        return response()->json([
            'message' => 'Form deleted successfully'
        ]);
    }

    /**
     * Upload material file for SAP form
     */
    public function uploadMaterial(Request $request, Form $form)
    {
        // Ensure the form belongs to the authenticated user
        if ($form->user_id !== $request->user()->id) {
            return response()->json([
                'error' => [
                    'code' => 'ROLE_FORBIDDEN',
                    'message' => 'You are not authorized to upload materials for this form',
                    'required_role' => 'owner'
                ]
            ], 403);
        }

        // Validate that this is a SAP form
        if ($form->type !== 'sap') {
            return response()->json([
                'error' => [
                    'code' => 'INVALID_FORM_TYPE',
                    'message' => 'Material upload is only allowed for SAP forms'
                ]
            ], 400);
        }

        \Log::info($request->file('file')->getMimeType());
        $request->validate([
            'file' => 'required|file|mimes:pdf,doc,docx,ppt,pptx|max:10240', // Max 10MB
        ]);

        if ($request->hasFile('file')) {
            $file = $request->file('file');
            $path = $file->store('sap_materials', 'public');

            $documentation = $form->documentations()->create([
                'file_path' => $path,
                'type' => 'materi',
            ]);

            return response()->json([
                'message' => 'Material uploaded successfully',
                'documentation' => $documentation
            ], 201);
        }

        return response()->json([
            'message' => 'No file uploaded'
        ], 400);
    }

    /**
     * Upload photo documentation for SAP form
     */
    public function uploadPhoto(Request $request, Form $form)
    {
        // Ensure the form belongs to the authenticated user
        if ($form->user_id !== $request->user()->id) {
            return response()->json([
                'error' => [
                    'code' => 'ROLE_FORBIDDEN',
                    'message' => 'You are not authorized to upload photos for this form',
                    'required_role' => 'owner'
                ]
            ], 403);
        }

        // Validate that this is a SAP form
        if ($form->type !== 'sap') {
            return response()->json([
                'error' => [
                    'code' => 'INVALID_FORM_TYPE',
                    'message' => 'Photo upload is only allowed for SAP forms'
                ]
            ], 400);
        }

        $request->validate([
            'file' => 'required|image|mimes:jpeg,png,jpg,gif,webp|max:10240', // Max 10MB
        ]);

        if ($request->hasFile('file')) {
            $file = $request->file('file');
            $path = $file->store('sap_photos', 'public');

            $documentation = $form->documentations()->create([
                'file_path' => $path,
                'type' => 'foto',
            ]);

            return response()->json([
                'message' => 'Photo uploaded successfully',
                'documentation' => $documentation
            ], 201);
        }

        return response()->json([
            'message' => 'No photo uploaded'
        ], 400);
    }

    /**
     * Display a listing of submitted forms only.
     */
    public function getSubmittedForms(Request $request)
    {
        // Check if user is dosen - only dosen should see submitted forms for review
        if ($request->user()->role !== 'dosen') {
            $query = Form::query();
            // Non-dosen users can only see their own submitted forms
            $query->where('user_id', $request->user()->id);
        } else {
            $query = Form::query();
        }

        // Filter by status = submitted
        $query->where('status', 'submitted');

        $forms = $query->with(['user', 'patient'])->orderBy('created_at', 'desc')->paginate(10);

        return response()->json($forms);
    }

    /**
     * Review a form and update its status.
     */
    public function reviewForm(Request $request, Form $form)
    {
        // Check if user is dosen
        if ($request->user()->role !== 'dosen') {
            return response()->json([
                'error' => [
                    'code' => 'ROLE_FORBIDDEN',
                    'message' => 'Only dosen can review forms',
                    'required_role' => 'dosen'
                ]
            ], 403);
        }

        $validated = $request->validate([
            'status' => 'required|in:revised,approved',
            'comment' => 'nullable|string',
        ]);

        // Update the form status
        $form->update([
            'status' => $validated['status']
        ]);

        // If status is revised, create a revision record
        if ($validated['status'] === 'revised') {
            $form->revisions()->create([
                'reviewed_by' => $request->user()->id,
                'comment' => $validated['comment'] ?? null,
            ]);
        }

        return response()->json([
            'message' => 'Form reviewed successfully',
            'form' => $form->load('revisions.reviewer')
        ]);
    }

    /**
     * Recursively validate nursing diagnosis and intervention ids inside the data payload
     */
    private function validateNursingIds(array $data)
    {
        foreach ($data as $key => $value) {
            if ($key === 'diagnosis') {
                if (is_numeric($value) && !NursingDiagnosis::where('id', $value)->exists()) {
                    throw ValidationException::withMessages(['data' => ['Invalid diagnosis id: ' . $value]]);
                }
            }
            if ($key === 'intervensi' && is_array($value)) {
                foreach ($value as $id) {
                    if (!is_numeric($id) || !NursingIntervention::where('id', $id)->exists()) {
                        throw ValidationException::withMessages(['data' => ['Invalid intervention id: ' . $id]]);
                    }
                }
            }

            // Recurse into nested arrays
            if (is_array($value)) {
                $this->validateNursingIds($value);
            }
        }
    }

    /**
     * Validate basic genogram structure shape.
     * Accepts either a list of members directly or an object {members: [], connections: []}
     */
    private function validateGenogramStructure($structure): bool
    {
        if ($structure === null) return false;

        // If JSON string, try to decode
        if (is_string($structure)) {
            $decoded = json_decode($structure, true);
            if ($decoded === null) return false;
            $structure = $decoded;
        }

        // If top-level is list, treat as members
        $members = [];
        $connections = [];
        if (is_array($structure) && isset($structure['members'])) {
            $members = $structure['members'];
            $connections = $structure['connections'] ?? [];
        } elseif (is_array($structure) && array_values($structure) !== $structure) {
            // associative but missing 'members' key - assume invalid
            return false;
        } elseif (is_array($structure)) {
            // numeric-indexed list: there are members
            $members = $structure;
        } else {
            return false;
        }

        if (!is_array($members) || count($members) === 0) return false;

        // collect ids and validate members
        $ids = [];
        foreach ($members as $m) {
            if (!is_array($m)) return false;
            if (!isset($m['name']) || trim($m['name']) === '') return false;
            if (!isset($m['id'])) return false;
            $ids[] = $m['id'];
        }

        // Validate connections if present
        if ($connections && !is_array($connections)) return false;
        foreach ($connections as $conn) {
            if (!is_array($conn)) return false;
            if (!isset($conn['from']) || !isset($conn['to'])) return false;
            if (!in_array($conn['from'], $ids) || !in_array($conn['to'], $ids)) return false;
            if (!isset($conn['type']) || trim($conn['type']) === '') return false;
        }

        return true;
    }

    /**
     * Create specific form model based on type
     */
    private function createSpecificForm(string $type, array $validated, array $allData)
    {
        $baseData = [
            'user_id' => $validated['user_id'],
            'patient_id' => $validated['patient_id'],
            'status' => $validated['status'],
        ];

        $formData = array_merge($baseData, $allData['data'] ?? []);

        switch ($type) {
            case 'pengkajian':
                return \App\Models\PengkajianForm::create($formData);
            case 'resume_kegawatdaruratan':
                return \App\Models\ResumeKegawatdaruratanForm::create($formData);
            case 'resume_poliklinik':
                return \App\Models\ResumePoliklinikForm::create($formData);
            case 'sap':
                return \App\Models\SapForm::create($formData);
            case 'catatan_tambahan':
                return \App\Models\CatatanTambahanForm::create($formData);
            default:
                throw new \Exception('Invalid form type');
        }
    }
}