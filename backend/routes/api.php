<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\PatientController;
use App\Http\Controllers\FormController;
use App\Http\Controllers\PdfController;
use App\Http\Controllers\DashboardController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::get('/health-check', function () {
    return response()->json(['status' => 'OK', 'timestamp' => now(), 'database' => DB::connection()->getPdo() ? 'Connected' : 'Disconnected'], 200);
});
// Patient routes - protected
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user/profile', [AuthController::class, 'getUserProfile']);
    Route::put('/user/profile', [AuthController::class, 'updateUserProfile']);

    Route::apiResource('patients', PatientController::class);

    // Form routes
    Route::get('forms/submitted', [FormController::class, 'getSubmittedForms']);
    Route::get('forms/submitted-test', function () {
        return response()->json(['test' => 'success']);
    });
    Route::post('forms/{form}/upload-material', [FormController::class, 'uploadMaterial']);
    Route::post('forms/{form}/upload-photo', [FormController::class, 'uploadPhoto']);
    Route::post('forms/{form}/review', [FormController::class, 'reviewForm']);
    Route::post('forms/{form}/generate-pdf', [PdfController::class, 'generate']);
    Route::get('forms/{form}/genogram/svg', [\App\Http\Controllers\GenogramController::class, 'render']);
    Route::apiResource('forms', FormController::class);

    // Nursing diagnoses routes - only for dosen
    Route::apiResource('diagnoses', \App\Http\Controllers\NursingDiagnosisController::class);
    // Nursing interventions routes - only for dosen
    Route::apiResource('interventions', \App\Http\Controllers\NursingInterventionController::class);

    // Dashboard statistics routes
    Route::get('dashboard/mahasiswa', [DashboardController::class, 'mahasiswaDashboard']);
    Route::get('dashboard/dosen', [DashboardController::class, 'dosenDashboard']);

});



