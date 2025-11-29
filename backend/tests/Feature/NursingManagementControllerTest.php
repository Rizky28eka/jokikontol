<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;
use App\Models\NursingDiagnosis;
use App\Models\NursingIntervention;

class NursingManagementControllerTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        // Add the role middleware
        $this->withoutMiddleware();
    }

    public function test_dosen_can_create_nursing_diagnosis()
    {
        $dosen = User::factory()->create(['role' => 'dosen']);

        $response = $this->withMiddleware()
            ->actingAs($dosen, 'sanctum')
            ->postJson('/api/diagnoses', [
                'name' => 'Gangguan Pola Tidur',
                'description' => 'Pasien mengalami kesulitan tidur'
            ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('nursing_diagnoses', [
            'name' => 'Gangguan Pola Tidur',
            'created_by' => $dosen->id,
        ]);
    }

    public function test_mahasiswa_cannot_create_nursing_diagnosis()
    {
        $mahasiswa = User::factory()->create(['role' => 'mahasiswa']);

        $response = $this->withMiddleware()
            ->actingAs($mahasiswa, 'sanctum')
            ->postJson('/api/diagnoses', [
                'name' => 'Gangguan Pola Tidur',
                'description' => 'Pasien mengalami kesulitan tidur'
            ]);

        $response->assertStatus(403);
    }

    public function test_dosen_can_get_all_nursing_diagnoses()
    {
        $dosen = User::factory()->create(['role' => 'dosen']);
        NursingDiagnosis::factory()->create([
            'name' => 'Diagnosis 1',
            'created_by' => $dosen->id
        ]);

        $response = $this->withMiddleware()
            ->actingAs($dosen, 'sanctum')
            ->getJson('/api/diagnoses');

        $response->assertStatus(200);
        $this->assertGreaterThanOrEqual(1, count($response->json()));
    }

    public function test_dosen_can_update_nursing_diagnosis()
    {
        $dosen = User::factory()->create(['role' => 'dosen']);
        $diagnosis = NursingDiagnosis::factory()->create([
            'name' => 'Old Name',
            'created_by' => $dosen->id
        ]);

        $response = $this->withMiddleware()
            ->actingAs($dosen, 'sanctum')
            ->putJson("/api/diagnoses/{$diagnosis->id}", [
                'name' => 'Updated Name',
                'description' => 'Updated description'
            ]);

        $response->assertStatus(200);
        $this->assertDatabaseHas('nursing_diagnoses', [
            'name' => 'Updated Name',
        ]);
    }

    public function test_dosen_can_delete_nursing_diagnosis()
    {
        $dosen = User::factory()->create(['role' => 'dosen']);
        $diagnosis = NursingDiagnosis::factory()->create([
            'name' => 'To Delete',
            'created_by' => $dosen->id
        ]);

        $response = $this->withMiddleware()
            ->actingAs($dosen, 'sanctum')
            ->deleteJson("/api/diagnoses/{$diagnosis->id}");

        $response->assertStatus(200);
        $this->assertDatabaseMissing('nursing_diagnoses', [
            'id' => $diagnosis->id,
        ]);
    }

    public function test_dosen_can_create_nursing_intervention()
    {
        $dosen = User::factory()->create(['role' => 'dosen']);

        $response = $this->withMiddleware()
            ->actingAs($dosen, 'sanctum')
            ->postJson('/api/interventions', [
                'name' => 'Terapi Relaksasi',
                'description' => 'Intervensi untuk mengurangi kecemasan'
            ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('nursing_interventions', [
            'name' => 'Terapi Relaksasi',
            'created_by' => $dosen->id,
        ]);
    }

    public function test_mahasiswa_cannot_create_nursing_intervention()
    {
        $mahasiswa = User::factory()->create(['role' => 'mahasiswa']);

        $response = $this->withMiddleware()
            ->actingAs($mahasiswa, 'sanctum')
            ->postJson('/api/interventions', [
                'name' => 'Terapi Relaksasi',
                'description' => 'Intervensi untuk mengurangi kecemasan'
            ]);

        $response->assertStatus(403);
    }
}