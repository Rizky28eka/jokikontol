<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;
use App\Models\User;
use App\Models\Patient;
use App\Models\Form;

class FormControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_create_resume_kegawatdaruratan_form()
    {
        $user = User::factory()->create();
        $patient = Patient::factory()->create();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/forms', [
                'type' => 'resume_kegawatdaruratan',
                'patient_id' => $patient->id,
                'data' => [
                    'identitas' => [
                        'nama_lengkap' => 'John Doe',
                        'umur' => '35',
                        'jenis_kelamin' => 'Laki-laki'
                    ]
                ]
            ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('forms', [
            'type' => 'resume_kegawatdaruratan',
            'patient_id' => $patient->id,
            'user_id' => $user->id,
        ]);
    }

    public function test_can_update_resume_kegawatdaruratan_form()
    {
        $user = User::factory()->create();
        $patient = Patient::factory()->create();
        
        $form = Form::factory()->create([
            'type' => 'resume_kegawatdaruratan',
            'user_id' => $user->id,
            'patient_id' => $patient->id
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->putJson("/api/forms/{$form->id}", [
                'type' => 'resume_kegawatdaruratan', // Include the type field
                'data' => [
                    'identitas' => [
                        'nama_lengkap' => 'Updated Name',
                        'umur' => '40'
                    ]
                ]
            ]);

        $response->assertStatus(200);
        $this->assertDatabaseHas('forms', [
            'id' => $form->id,
            'type' => 'resume_kegawatdaruratan',
            'user_id' => $user->id,
        ]);
    }

    public function test_can_list_forms_by_type()
    {
        $user = User::factory()->create();
        $patient = Patient::factory()->create();

        Form::factory()->create([
            'type' => 'resume_kegawatdaruratan',
            'user_id' => $user->id,
            'patient_id' => $patient->id
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/forms?type=resume_kegawatdaruratan');

        $response->assertStatus(200);
        $response->assertJsonFragment([
            'type' => 'resume_kegawatdaruratan'
        ]);
    }

    public function test_can_store_pengkajian_form()
    {
        $user = User::factory()->create();
        $patient = Patient::factory()->create();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/forms', [
                'type' => 'pengkajian',
                'patient_id' => $patient->id,
                'data' => []
            ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('forms', [
            'type' => 'pengkajian',
            'patient_id' => $patient->id,
            'user_id' => $user->id,
        ]);
    }

    public function test_can_store_complete_resume_kegawatdaruratan_form_with_complex_data()
    {
        $user = User::factory()->create();
        $patient = Patient::factory()->create();

        $complexFormData = [
            'identitas' => [
                'nama_lengkap' => 'John Doe',
                'umur' => '35',
                'jenis_kelamin' => 'Laki-laki',
                'alamat' => 'Jl. Contoh No. 123',
                'tanggal_masuk' => '2025-01-01'
            ],
            'riwayat_keluhan' => [
                'keluhan_utama' => 'Gelisah dan tidak bisa tidur',
                'riwayat_penyakit_sekarang' => 'Pasien mengalami gejala sejak 1 minggu yang lalu...',
                'faktor_pencetus' => 'Stres pekerjaan'
            ],
            'pemeriksaan_fisik' => [
                'keadaan_umum' => 'Tampak gelisah',
                'tanda_vital' => 'TD: 120/80, N: 88x/m, S: 36.5C',
                'pemeriksaan_lain' => 'Tidak ditemukan kelainan fisik signifikan'
            ],
            'status_mental' => [
                'kesadaran' => 'Compos mentis',
                'orientasi' => 'Orientasi tempat dan waktu baik',
                'bentuk_pemikiran' => 'Koheren, relevan',
                'isi_pemikiran' => 'Waham tidak ada',
                'persepsi' => 'Halusinasi auditorik (+)'
            ],
            'diagnosis' => [
                'diagnosis_utama' => 'Gangguan Cemas',
                'diagnosis_banding' => 'Depresi',
                'diagnosis_tambahan' => 'Gangguan Tidur'
            ],
            'tindakan' => [
                'tindakan_medis' => 'Pemberian obat antipsikotik',
                'tindakan_keperawatan' => 'Terapi relaksasi',
                'terapi_psikososial' => 'Terapi kognitif perilaku'
            ],
            'implementasi' => [
                'pelaksanaan_intervensi' => 'Intervensi dilakukan sesuai rencana...',
                'kolaborasi_tim' => 'Kolaborasi dengan psikiater dan psikolog',
                'edukasi' => 'Edukasi tentang pentingnya minum obat teratur'
            ],
            'evaluasi' => [
                'respon_intervensi' => 'Pasien menunjukkan respon baik terhadap terapi',
                'perubahan_klinis' => 'Gejala cemas berkurang',
                'tujuan_tercapai' => 'Tidur membaik',
                'hambatan_perawatan' => 'Keterbatasan keluarga untuk mendampingi'
            ],
            'rencana_lanjut' => [
                'rencana_medis' => 'Lanjutkan pengobatan',
                'rencana_keperawatan' => 'Lanjutkan terapi relaksasi',
                'rencana_pemantauan' => 'Kontrol 2 minggu lagi'
            ],
            'rencana_keluarga' => [
                'keterlibatan_keluarga' => 'Keluarga aktif membantu perawatan',
                'edukasi_keluarga' => 'Edukasi tanda bahaya dan cara menangani krisis',
                'dukungan_keluarga' => 'Keluarga siap memberikan dukungan emosional'
            ],
            'renpra' => [
                'diagnosis' => 'Gangguan pola tidur',
                'intervensi' => ['Terapi Individu', 'Manajemen Agresi'],
                'tujuan' => 'Pasien mampu tidur dengan baik',
                'kriteria' => 'Tidur 6-8 jam/hari',
                'rasional' => 'Terapi relaksasi efektif untuk gangguan tidur',
                'evaluasi' => 'Evaluasi setelah 1 minggu terapi'
            ]
        ];

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/forms', [
                'type' => 'resume_kegawatdaruratan',
                'patient_id' => $patient->id,
                'data' => $complexFormData
            ]);

        $response->assertStatus(201);

        // Verify the complex data is stored correctly
        $form = \App\Models\Form::where('type', 'resume_kegawatdaruratan')->first();
        $this->assertEquals($complexFormData, $form->data);
    }

    public function test_can_create_resume_poliklinik_form()
    {
        $user = User::factory()->create();
        $patient = Patient::factory()->create();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/forms', [
                'type' => 'resume_poliklinik',
                'patient_id' => $patient->id,
                'data' => [
                    'section_1' => [
                        'nama_lengkap' => 'Jane Doe',
                        'umur' => '40',
                        'jenis_kelamin' => 'Perempuan',
                        'status_perkawinan' => 'Menikah'
                    ],
                    'section_2' => [
                        'riwayat_pendidikan' => 'Sarjana',
                        'pekerjaan' => 'Guru',
                        'riwayat_keluarga' => 'Riwayat gangguan jiwa dalam keluarga ...'
                    ],
                    'section_3' => [
                        'hubungan_sosial' => 'Pasien memiliki hubungan yang baik dengan keluarga',
                        'dukungan_sosial' => 'Didukung oleh keluarga',
                        'stresor_psikososial' => 'Stres kerja'
                    ],
                    'section_4' => [
                        'riwayat_gangguan_psikiatri' => 'Anxiety sejak 2 tahun lalu',
                        'riwayat_pengobatan' => 'Minum obat teratur'
                    ],
                    'section_5' => [
                        'kesadaran' => 'Compos mentis',
                        'orientasi' => 'Orientasi waktu baik',
                        'penampilan' => 'Rapi'
                    ],
                    'section_6' => [
                        'mood' => 'Sedih',
                        'afect' => 'Restricted',
                        'alam_pikiran' => 'Delusi tidak ada'
                    ],
                    'section_7' => [
                        'fungsi_sosial' => 'Menurun',
                        'interaksi_sosial' => 'Kurang aktif bermasyarakat'
                    ],
                    'section_8' => [
                        'kepercayaan' => 'Islam',
                        'praktik_ibadah' => 'Sholat teratur'
                    ],
                    'section_9' => [
                        'diagnosis' => 'Depresi',
                        'intervensi' => ['Terapi Individu', 'Terapi Keluarga'],
                        'tujuan' => 'Mood membaik',
                        'kriteria' => 'Pasien mampu mengungkapkan perasaan dengan baik',
                        'rasional' => 'Terapi membantu mengatasi depresi'
                    ],
                    'section_10' => [
                        'catatan_tambahan' => 'Klien memerlukan dukungan keluarga lebih lanjut',
                        'tanggal_pengisian' => '2025-01-01'
                    ]
                ]
            ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('forms', [
            'type' => 'resume_poliklinik',
            'patient_id' => $patient->id,
            'user_id' => $user->id,
        ]);
    }
}