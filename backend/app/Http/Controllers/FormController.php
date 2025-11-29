<?php

namespace App\Http\Controllers;

use App\Models\Form;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

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

        $forms = $query->orderBy('created_at', 'desc')->paginate(10);

        return response()->json($forms);
    }

    /**
     * Store a newly created form in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'type' => 'required|string|in:pengkajian,resume_kegawatdaruratan,resume_poliklinik,sap,catatan_tambahan', // Allow all form types including 'catatan_tambahan'
            'patient_id' => 'required|exists:patients,id',
            'data' => 'nullable|array',
            'status' => 'sometimes|in:draft,submitted,revised,approved',
        ]);

        $validated['user_id'] = $request->user()->id;
        $validated['status'] = $validated['status'] ?? 'draft';

        $form = Form::create($validated);

        // If the form type is pengkajian and it includes genogram data, create the genogram
        if ($validated['type'] === 'pengkajian' && isset($validated['data']['genogram'])) {
            $form->genogram()->create([
                'structure' => $validated['data']['genogram']['structure'] ?? null,
                'notes' => $validated['data']['genogram']['notes'] ?? null,
            ]);
        }

        return response()->json([
            'message' => 'Form created successfully',
            'form' => $form->load('genogram')
        ], 201);
    }

    /**
     * Display the specified form.
     */
    public function show(Request $request, Form $form)
    {
        // Ensure the form belongs to the authenticated user
        if ($form->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        return response()->json($form->load('genogram'));
    }

    /**
     * Update the specified form in storage.
     */
    public function update(Request $request, Form $form)
    {
        // Ensure the form belongs to the authenticated user
        if ($form->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        $validated = $request->validate([
            'type' => 'sometimes|required|string|in:pengkajian,resume_kegawatdaruratan,resume_poliklinik,sap,catatan_tambahan',
            'patient_id' => 'sometimes|required|exists:patients,id',
            'data' => 'nullable|array',
            'status' => 'sometimes|in:draft,submitted,revised,approved',
        ]);

        $form->update($validated);

        // If the form type is pengkajian and it includes genogram data, update or create the genogram
        if (($validated['type'] ?? $form->type) === 'pengkajian' && isset($validated['data']['genogram'])) {
            if ($form->genogram) {
                $form->genogram()->update([
                    'structure' => $validated['data']['genogram']['structure'] ?? null,
                    'notes' => $validated['data']['genogram']['notes'] ?? null,
                ]);
            } else {
                $form->genogram()->create([
                    'structure' => $validated['data']['genogram']['structure'] ?? null,
                    'notes' => $validated['data']['genogram']['notes'] ?? null,
                ]);
            }
        }

        return response()->json([
            'message' => 'Form updated successfully',
            'form' => $form->load('genogram')
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
                'message' => 'Unauthorized'
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
                'message' => 'Unauthorized'
            ], 403);
        }

        // Validate that this is a SAP form
        if ($form->type !== 'sap') {
            return response()->json([
                'message' => 'Material upload is only allowed for SAP forms'
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
                'message' => 'Unauthorized'
            ], 403);
        }

        // Validate that this is a SAP form
        if ($form->type !== 'sap') {
            return response()->json([
                'message' => 'Photo upload is only allowed for SAP forms'
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
                'message' => 'Unauthorized: Only dosen can review forms'
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
}