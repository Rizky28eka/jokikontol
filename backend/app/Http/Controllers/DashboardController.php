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

        $statistics = [
            'total_pasien' => Patient::where('created_by', $userId)->count(),
            'total_form' => Form::where('user_id', $userId)->count(),
            'form_disetujui' => Form::where('user_id', $userId)->where('status', 'approved')->count(),
            'form_menunggu' => Form::where('user_id', $userId)->where('status', 'submitted')->count(),
        ];

        return response()->json($statistics);
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
                'message' => 'Unauthorized: Only dosen can access this endpoint'
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
