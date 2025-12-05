<?php

namespace App\Http\Controllers;

use App\Models\PengkajianForm;
use App\Models\Form;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PengkajianFormController extends Controller
{
    public function index(Request $request)
    {
        $query = PengkajianForm::with(['user', 'patient']);

        if ($request->has('patient_id')) {
            $query->where('patient_id', $request->patient_id);
        }

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        $forms = $query->latest()->get();

        return response()->json(['data' => $forms]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'patient_id' => 'required|exists:patients,id',
            'status' => 'in:draft,submitted,revised,approved',
        ]);

        $validated['user_id'] = Auth::id();

        $pengkajianForm = PengkajianForm::create(array_merge($validated, $request->except(['patient_id', 'status'])));

        // Create polymorphic reference in forms table
        Form::create([
            'type' => 'pengkajian',
            'user_id' => Auth::id(),
            'patient_id' => $request->patient_id,
            'status' => $request->status ?? 'draft',
            'formable_type' => PengkajianForm::class,
            'formable_id' => $pengkajianForm->id,
        ]);

        return response()->json(['form' => $pengkajianForm->load(['user', 'patient'])], 201);
    }

    public function show($id)
    {
        $form = PengkajianForm::with(['user', 'patient'])->findOrFail($id);
        return response()->json($form);
    }

    public function update(Request $request, $id)
    {
        $form = PengkajianForm::findOrFail($id);

        $validated = $request->validate([
            'status' => 'in:draft,submitted,revised,approved',
        ]);

        $form->update(array_merge($validated, $request->except(['patient_id', 'user_id'])));

        // Update main form status
        Form::where('formable_type', PengkajianForm::class)
            ->where('formable_id', $id)
            ->update(['status' => $request->status ?? $form->status]);

        return response()->json(['form' => $form->load(['user', 'patient'])]);
    }

    public function destroy($id)
    {
        $form = PengkajianForm::findOrFail($id);
        
        // Delete polymorphic reference
        Form::where('formable_type', PengkajianForm::class)
            ->where('formable_id', $id)
            ->delete();
        
        $form->delete();

        return response()->json(['message' => 'Form deleted successfully']);
    }
}
