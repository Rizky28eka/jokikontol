<?php

namespace App\Http\Controllers;

use App\Models\Form;
use Illuminate\Http\Request;
use Barryvdh\DomPDF\Facade\Pdf as PDF;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;

class PdfController extends Controller
{
    /**
     * Generate a PDF for a specific form
     */
    public function generate(Request $request, Form $form)
    {
        // Ensure the form belongs to the authenticated user or is accessible by dosen
        if ($form->user_id !== $request->user()->id && $request->user()->role !== 'dosen') {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        // Create directory if it doesn't exist
        $directory = 'pdfs';
        if (!Storage::disk('public')->exists($directory)) {
            Storage::disk('public')->makeDirectory($directory);
        }

        // Generate PDF based on form type
        switch ($form->type) {
            case 'pengkajian':
                $pdf = $this->generatePengkajianPdf($form);
                break;
            case 'resume_kegawatdaruratan':
                $pdf = $this->generateResumeKegawatdaruratanPdf($form);
                break;
            case 'resume_poliklinik':
                $pdf = $this->generateResumePoliklinikPdf($form);
                break;
            case 'sap':
                $pdf = $this->generateSapPdf($form);
                break;
            case 'catatan_tambahan':
                $pdf = $this->generateCatatanTambahanPdf($form);
                break;
            default:
                return response()->json([
                    'message' => 'Form type not supported for PDF generation'
                ], 400);
        }

        // Generate a unique filename
        $filename = "form_{$form->id}_" . time() . ".pdf";
        $path = $directory . '/' . $filename;

        // Save the PDF to storage
        Storage::disk('public')->put($path, $pdf->output());

        // Return the public URL
        $url = Storage::disk('public')->url($path);

        return response()->json([
            'message' => 'PDF generated successfully',
            'url' => url($url)
        ]);
    }

    /**
     * Generate PDF for Pengkajian form
     */
    private function generatePengkajianPdf($form)
    {
        $data = $form->data ?? [];
        $patient = $form->patient;
        $user = $form->user;
        $genogram = $form->genogram;

        $pdf = PDF::loadView('pdf.pengkajian', [
            'form' => $form,
            'patient' => $patient,
            'user' => $user,
            'genogram' => $genogram,
            'data' => $data
        ]);

        return $pdf;
    }

    /**
     * Generate PDF for Resume Kegawatdaruratan form
     */
    private function generateResumeKegawatdaruratanPdf($form)
    {
        $data = $form->data ?? [];
        $patient = $form->patient;
        $user = $form->user;
        $genogram = $form->genogram;

        $pdf = PDF::loadView('pdf.resume_kegawatdaruratan', [
            'form' => $form,
            'patient' => $patient,
            'user' => $user,
            'genogram' => $genogram,
            'data' => $data
        ]);

        return $pdf;
    }

    /**
     * Generate PDF for Resume Poliklinik form
     */
    private function generateResumePoliklinikPdf($form)
    {
        $data = $form->data ?? [];
        $patient = $form->patient;
        $user = $form->user;
        $genogram = $form->genogram;

        $pdf = PDF::loadView('pdf.resume_poliklinik', [
            'form' => $form,
            'patient' => $patient,
            'user' => $user,
            'genogram' => $genogram,
            'data' => $data
        ]);

        return $pdf;
    }

    /**
     * Generate PDF for SAP form
     */
    private function generateSapPdf($form)
    {
        $data = $form->data ?? [];
        $patient = $form->patient;
        $user = $form->user;
        $genogram = $form->genogram;

        // Include documentations if available
        $documentations = $form->documentations;

        $pdf = PDF::loadView('pdf.sap', [
            'form' => $form,
            'patient' => $patient,
            'user' => $user,
            'genogram' => $genogram,
            'data' => $data,
            'documentations' => $documentations
        ]);

        return $pdf;
    }

    /**
     * Generate PDF for Catatan Tambahan form
     */
    private function generateCatatanTambahanPdf($form)
    {
        $data = $form->data ?? [];
        $patient = $form->patient;
        $user = $form->user;
        $genogram = $form->genogram;

        $pdf = PDF::loadView('pdf.catatan_tambahan', [
            'form' => $form,
            'patient' => $patient,
            'user' => $user,
            'genogram' => $genogram,
            'data' => $data
        ]);

        return $pdf;
    }
}
