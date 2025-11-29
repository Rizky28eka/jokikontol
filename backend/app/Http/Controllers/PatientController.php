<?php

namespace App\Http\Controllers;

use App\Models\Patient;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class PatientController extends Controller
{
    /**
     * Display a listing of the patients.
     */
    public function index(Request $request)
    {
        $patients = Patient::where('created_by', $request->user()->id)
            ->orderBy('created_at', 'desc')
            ->paginate(10);

        return response()->json($patients);
    }

    /**
     * Store a newly created patient in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'gender' => 'required|in:L,P',
            'age' => 'required|integer|min:0|max:150',
            'address' => 'required|string|max:500',
            'rm_number' => 'required|string|max:50|unique:patients,rm_number',
        ]);

        $validated['created_by'] = $request->user()->id;

        $patient = Patient::create($validated);

        return response()->json([
            'message' => 'Patient created successfully',
            'patient' => $patient
        ], 201);
    }

    /**
     * Display the specified patient.
     */
    public function show(Request $request, Patient $patient)
    {
        // Ensure the patient belongs to the authenticated user
        if ($patient->created_by !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        return response()->json($patient);
    }

    /**
     * Update the specified patient in storage.
     */
    public function update(Request $request, Patient $patient)
    {
        // Ensure the patient belongs to the authenticated user
        if ($patient->created_by !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'gender' => 'sometimes|required|in:L,P',
            'age' => 'sometimes|required|integer|min:0|max:150',
            'address' => 'sometimes|required|string|max:500',
            'rm_number' => [
                'sometimes',
                'required',
                'string',
                'max:50',
                Rule::unique('patients')->ignore($patient->id)
            ],
        ]);

        $patient->update($validated);

        return response()->json([
            'message' => 'Patient updated successfully',
            'patient' => $patient
        ]);
    }

    /**
     * Remove the specified patient from storage.
     */
    public function destroy(Request $request, Patient $patient)
    {
        // Ensure the patient belongs to the authenticated user
        if ($patient->created_by !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        $patient->delete();

        return response()->json([
            'message' => 'Patient deleted successfully'
        ]);
    }
}