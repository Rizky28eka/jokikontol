<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;
use App\Models\Patient;
use App\Models\Form;

class CatatanTambahanFormControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_create_catatan_tambahan_form()
    {
        $user = User::factory()->create();
        $patient = Patient::factory()->create();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/forms', [
                'type' => 'catatan_tambahan',
                'patient_id' => $patient->id,
                'data' => [
                    'catatan' => [
                        'isi_catatan' => 'Ini adalah catatan tambahan yang sangat penting untuk pasien ini. Banyak hal yang perlu dicatat terkait perkembangan pasien.',
                        'renpra' => [
                            'diagnosis' => 'Depresi',
                            'intervensi' => ['Terapi Individu', 'Terapi Keluarga'],
                            'tujuan' => 'Meningkatkan mood pasien',
                            'kriteria' => 'Pasien mampu mengungkapkan perasaan',
                            'rasional' => 'Terapi membantu pasien memproses emosi'
                        ]
                    ]
                ]
            ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('forms', [
            'type' => 'catatan_tambahan',
            'patient_id' => $patient->id,
            'user_id' => $user->id,
        ]);
    }

    public function test_can_create_catatan_tambahan_form_without_renpra()
    {
        $user = User::factory()->create();
        $patient = Patient::factory()->create();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/forms', [
                'type' => 'catatan_tambahan',
                'patient_id' => $patient->id,
                'data' => [
                    'catatan' => [
                        'isi_catatan' => 'Catatan tanpa renpra. Hanya mencatat perkembangan pasien secara umum.'
                    ]
                ]
            ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('forms', [
            'type' => 'catatan_tambahan',
            'patient_id' => $patient->id,
            'user_id' => $user->id,
        ]);
    }

    public function test_can_update_catatan_tambahan_form()
    {
        $user = User::factory()->create();
        $patient = Patient::factory()->create();
        
        $form = Form::factory()->create([
            'type' => 'catatan_tambahan',
            'user_id' => $user->id,
            'patient_id' => $patient->id
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->putJson("/api/forms/{$form->id}", [
                'type' => 'catatan_tambahan', // Include type field for update
                'data' => [
                    'catatan' => [
                        'isi_catatan' => 'Catatan telah diperbarui dengan informasi terbaru',
                        'renpra' => [
                            'diagnosis' => 'Anxiety',
                            'tujuan' => 'Mengurangi gejala anxiety'
                        ]
                    ]
                ]
            ]);

        $response->assertStatus(200);
        $this->assertDatabaseHas('forms', [
            'id' => $form->id,
            'type' => 'catatan_tambahan',
            'user_id' => $user->id,
        ]);
    }
}