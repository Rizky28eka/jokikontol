<?php

namespace App\Http\Controllers;

use App\Models\NursingIntervention;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class NursingInterventionController extends Controller
{
    /**
     * Display a listing of the nursing interventions.
     */
    public function index(): JsonResponse
    {
        $interventions = NursingIntervention::with('createdBy')->orderBy('name')->get();
        return response()->json($interventions);
    }

    /**
     * Store a newly created nursing intervention in storage.
     */
    public function store(Request $request): JsonResponse
    {
        // Check if user is dosen
        if ($request->user()->role !== 'dosen') {
            return response()->json([
                'message' => 'Unauthorized: Only dosen can create interventions'
            ], 403);
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255|unique:nursing_interventions,name',
            'description' => 'nullable|string',
        ]);

        $validated['created_by'] = $request->user()->id;

        $intervention = NursingIntervention::create($validated);

        return response()->json([
            'message' => 'Intervention created successfully',
            'intervention' => $intervention->load('createdBy')
        ], 201);
    }

    /**
     * Display the specified nursing intervention.
     */
    public function show(NursingIntervention $nursingIntervention): JsonResponse
    {
        return response()->json($nursingIntervention->load('createdBy'));
    }

    /**
     * Update the specified nursing intervention in storage.
     */
    public function update(Request $request, NursingIntervention $nursingIntervention): JsonResponse
    {
        // Check if user is dosen
        if ($request->user()->role !== 'dosen') {
            return response()->json([
                'message' => 'Unauthorized: Only dosen can update interventions'
            ], 403);
        }

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255|unique:nursing_interventions,name,' . $nursingIntervention->id,
            'description' => 'nullable|string',
        ]);

        $nursingIntervention->update($validated);

        return response()->json([
            'message' => 'Intervention updated successfully',
            'intervention' => $nursingIntervention->load('createdBy')
        ]);
    }

    /**
     * Remove the specified nursing intervention from storage.
     */
    public function destroy(Request $request, NursingIntervention $nursingIntervention): JsonResponse
    {
        // Check if user is dosen
        if ($request->user()->role !== 'dosen') {
            return response()->json([
                'message' => 'Unauthorized: Only dosen can delete interventions'
            ], 403);
        }

        // Check if the intervention was created by the current user
        if ($nursingIntervention->created_by !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized: You can only delete interventions you created'
            ], 403);
        }

        $nursingIntervention->delete();

        return response()->json([
            'message' => 'Intervention deleted successfully'
        ]);
    }
}
