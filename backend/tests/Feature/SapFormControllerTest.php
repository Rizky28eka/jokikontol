<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;
use App\Models\User;
use App\Models\Patient;
use App\Models\Form;
use App\Models\Documentation;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

class SapFormControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_create_sap_form()
    {
        $user = User::factory()->create();
        $patient = Patient::factory()->create();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/forms', [
                'type' => 'sap',
                'patient_id' => $patient->id,
                'data' => [
                    'identitas' => [
                        'topik' => 'Kesehatan Mental Remaja',
                        'sasaran' => 'Siswa SMA',
                        'waktu' => '2 jam',
                        'tempat' => 'Aula Sekolah'
                    ],
                    'tujuan' => [
                        'umum' => 'Meningkatkan pemahaman tentang kesehatan mental',
                        'khusus' => 'Siswa mampu mengenali gejala gangguan mental'
                    ],
                    'materi_dan_metode' => [
                        'materi' => 'Pengantar kesehatan mental',
                        'metode' => 'Ceramah, diskusi'
                    ],
                    'joblist' => [
                        'roles' => ['Penyuluh', 'Moderator', 'Fasilitator']
                    ],
                    'pengorganisasian' => [
                        'penyuluh' => 'Dr. Ani',
                        'moderator' => 'Budi',
                        'fasilitator' => 'Citra'
                    ],
                    'tabel_kegiatan' => [
                        [
                            'tahap' => 'Pembukaan',
                            'waktu' => '10 menit',
                            'kegiatan_penyuluh' => 'Memperkenalkan materi',
                            'kegiatan_peserta' => 'Mendengarkan'
                        ]
                    ],
                    'evaluasi' => [
                        'input' => 'Peserta siap menerima materi',
                        'proses' => 'Diskusi berjalan lancar',
                        'hasil' => 'Tujuan tercapai'
                    ],
                    'feedback' => [
                        'pertanyaan' => 'Apa beda stress dan depresi?',
                        'saran' => 'Tambahan contoh kasus'
                    ],
                    'renpra' => [
                        'diagnosis' => 'Tidak Ada'
                    ]
                ]
            ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('forms', [
            'type' => 'sap',
            'patient_id' => $patient->id,
            'user_id' => $user->id,
        ]);
    }

    public function test_can_upload_material_to_sap_form()
    {
        Storage::fake('public');

        $user = User::factory()->create();
        $patient = Patient::factory()->create();

        $form = Form::factory()->create([
            'type' => 'sap',
            'user_id' => $user->id,
            'patient_id' => $patient->id
        ]);

        $file = UploadedFile::fake()->create('materi.pdf', 1000, 'application/pdf');

        $response = $this->actingAs($user, 'sanctum')
            ->post("/api/forms/{$form->id}/upload-material", [
                'file' => $file,
            ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('documentations', [
            'form_id' => $form->id,
            'type' => 'materi',
        ]);
    }

    public function test_cannot_upload_material_to_non_sap_form()
    {
        Storage::fake('public');

        $user = User::factory()->create();
        $patient = Patient::factory()->create();

        $form = Form::factory()->create([
            'type' => 'pengkajian', // Not SAP
            'user_id' => $user->id,
            'patient_id' => $patient->id
        ]);

        $file = UploadedFile::fake()->create('materi.pdf', 1000, 'application/pdf');

        $response = $this->actingAs($user, 'sanctum')
            ->post("/api/forms/{$form->id}/upload-material", [
                'file' => $file,
            ]);

        $response->assertStatus(400);
    }

    public function test_can_upload_photo_to_sap_form()
    {
        Storage::fake('public');

        $user = User::factory()->create();
        $patient = Patient::factory()->create();

        $form = Form::factory()->create([
            'type' => 'sap',
            'user_id' => $user->id,
            'patient_id' => $patient->id
        ]);

        $file = UploadedFile::fake()->image('foto.jpg', 600, 400);

        $response = $this->actingAs($user, 'sanctum')
            ->post("/api/forms/{$form->id}/upload-photo", [
                'file' => $file,
            ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('documentations', [
            'form_id' => $form->id,
            'type' => 'foto',
        ]);
    }

    public function test_cannot_upload_photo_to_non_sap_form()
    {
        Storage::fake('public');

        $user = User::factory()->create();
        $patient = Patient::factory()->create();

        $form = Form::factory()->create([
            'type' => 'resume_kegawatdaruratan', // Not SAP
            'user_id' => $user->id,
            'patient_id' => $patient->id
        ]);

        $file = UploadedFile::fake()->image('foto.jpg', 600, 400);

        $response = $this->actingAs($user, 'sanctum')
            ->post("/api/forms/{$form->id}/upload-photo", [
                'file' => $file,
            ]);

        $response->assertStatus(400);
    }
}