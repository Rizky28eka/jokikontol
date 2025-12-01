<?php

namespace App\Http\Controllers;

use App\Models\Form;
use App\Models\Patient;
use App\Models\User;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    /**
     * Get dashboard statistics for mahasiswa
     */
    public function mahasiswaDashboard(Request $request)
    {
        $userId = $request->user()->id;
        $totalForms = Form::where('user_id', $userId)->count();
        $approved = Form::where('user_id', $userId)->where('status', 'approved')->count();
        $waitingReview = Form::where('user_id', $userId)->where('status', 'submitted')->count();
        $revised = Form::where('user_id', $userId)->where('status', 'revised')->count();

        // Genogram completeness: count forms with a genogram structure present
        $genogramComplete = Form::where('user_id', $userId)
            ->whereHas('genogram', function($q) { $q->whereNotNull('structure'); })
            ->count();
        $genogramCompletePercent = $totalForms > 0 ? round(($genogramComplete / $totalForms) * 100, 2) : 0;

        $statistics = [
            'total_pasien' => Patient::where('created_by', $userId)->count(),
            'total_form' => $totalForms,
            'form_disetujui' => $approved,
            'form_menunggu_review' => $waitingReview,
            'form_revisi' => $revised,
            'genogram_complete_percent' => $genogramCompletePercent,
        ];

        return response()->json(['statistics' => $statistics]);
    }

    /**
     * Get dashboard statistics for dosen
     */
    public function dosenDashboard(Request $request)
    {
        $userId = $request->user()->id;
        $userRole = $request->user()->role;

        // Only allow dosen to access this endpoint
        if ($userRole !== 'dosen') {
            return response()->json([
                'error' => [
                    'code' => 'ROLE_FORBIDDEN',
                    'message' => 'Only dosen can access this endpoint',
                    'required_role' => 'dosen'
                ]
            ], 403);
        }

        $statistics = [
            'total_mahasiswa' => User::where('role', 'mahasiswa')->count(),
            'total_form' => Form::count(),
            'form_menunggu_review' => Form::where('status', 'submitted')->count(),
            'form_disetujui' => Form::where('status', 'approved')->count(),
        ];

        return response()->json($statistics);
    }
}
