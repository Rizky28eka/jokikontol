<?php

namespace App\Http\Controllers;

use App\Models\NursingDiagnosis;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class NursingDiagnosisController extends Controller
{
    /**
     * Display a listing of the nursing diagnoses.
     */
    public function index(): JsonResponse
    {
        $diagnoses = NursingDiagnosis::with('createdBy')->orderBy('name')->get();
        return response()->json($diagnoses);
    }

    /**
     * Store a newly created nursing diagnosis in storage.
     */
    public function store(Request $request): JsonResponse
    {
        // Check if user is dosen
        if ($request->user()->role !== 'dosen') {
            return response()->json([
                'message' => 'Unauthorized: Only dosen can create diagnoses'
            ], 403);
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255|unique:nursing_diagnoses,name',
            'description' => 'nullable|string',
        ]);

        $validated['created_by'] = $request->user()->id;

        $diagnosis = NursingDiagnosis::create($validated);

        return response()->json([
            'message' => 'Diagnosis created successfully',
            'diagnosis' => $diagnosis->load('createdBy')
        ], 201);
    }

    /**
     * Display the specified nursing diagnosis.
     */
    public function show(NursingDiagnosis $nursingDiagnosis): JsonResponse
    {
        return response()->json($nursingDiagnosis->load('createdBy'));
    }

    /**
     * Update the specified nursing diagnosis in storage.
     */
    public function update(Request $request, NursingDiagnosis $nursingDiagnosis): JsonResponse
    {
        // Check if user is dosen
        if ($request->user()->role !== 'dosen') {
            return response()->json([
                'message' => 'Unauthorized: Only dosen can update diagnoses'
            ], 403);
        }

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255|unique:nursing_diagnoses,name,' . $nursingDiagnosis->id,
            'description' => 'nullable|string',
        ]);

        $nursingDiagnosis->update($validated);

        return response()->json([
            'message' => 'Diagnosis updated successfully',
            'diagnosis' => $nursingDiagnosis->load('createdBy')
        ]);
    }

    /**
     * Remove the specified nursing diagnosis from storage.
     */
    public function destroy(Request $request, NursingDiagnosis $nursingDiagnosis): JsonResponse
    {
        // Check if user is dosen
        if ($request->user()->role !== 'dosen') {
            return response()->json([
                'message' => 'Unauthorized: Only dosen can delete diagnoses'
            ], 403);
        }

        // Check if the diagnosis was created by the current user or if it's a system admin
        if ($nursingDiagnosis->created_by !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized: You can only delete diagnoses you created'
            ], 403);
        }

        $nursingDiagnosis->delete();

        return response()->json([
            'message' => 'Diagnosis deleted successfully'
        ]);
    }
}
