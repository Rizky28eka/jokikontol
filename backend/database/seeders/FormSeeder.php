<?php

namespace Database\Seeders;

use App\Models\Form;
use App\Models\Patient;
use App\Models\User;
use Illuminate\Database\Seeder;

class FormSeeder extends Seeder
{
    public function run(): void
    {
        $mahasiswa = User::where('role', 'mahasiswa')->first();
        $patients = Patient::all();

        // Form Pengkajian Kesehatan Jiwa
        Form::create([
            'type' => 'pengkajian',
            'user_id' => $mahasiswa->id,
            'patient_id' => $patients[0]->id,
            'status' => 'submitted',
            'data' => [
                'identitas_klien' => [
                    'nama' => 'Ahmad Fauzi',
                    'umur' => 35,
                    'jenis_kelamin' => 'L',
                    'alamat' => 'Jl. Merdeka No. 123, Jakarta Pusat',
                ],
                'keluhan_utama' => 'Merasa cemas berlebihan dan sulit tidur',
                'riwayat_penyakit' => 'Pasien mengalami gangguan kecemasan sejak 3 bulan terakhir',
                'pemeriksaan_fisik' => [
                    'tekanan_darah' => '130/80',
                    'nadi' => '88',
                    'suhu' => '36.5',
                ],
                'status_mental' => [
                    'penampilan' => 'Rapi, sesuai usia',
                    'kesadaran' => 'Compos mentis',
                    'orientasi' => 'Baik terhadap waktu, tempat, dan orang',
                    'mood' => 'Cemas',
                    'afek' => 'Sesuai',
                ],
                'tanggal_pengisian' => now()->toIso8601String(),
            ],
        ]);

        // Form Resume Kegawatdaruratan
        Form::create([
            'type' => 'resume_kegawatdaruratan',
            'user_id' => $mahasiswa->id,
            'patient_id' => $patients[1]->id,
            'status' => 'submitted',
            'data' => [
                'identitas' => [
                    'nama_lengkap' => 'Siti Nurhaliza',
                    'umur' => 28,
                    'jenis_kelamin' => 'P',
                    'alamat' => 'Jl. Sudirman No. 45, Bandung',
                    'tanggal_masuk' => now()->toIso8601String(),
                ],
                'riwayat_keluhan' => [
                    'keluhan_utama' => 'Halusinasi pendengaran',
                    'riwayat_penyakit_sekarang' => 'Pasien mendengar suara-suara sejak 2 hari yang lalu',
                    'faktor_pencetus' => 'Stres pekerjaan',
                ],
                'pemeriksaan_fisik' => [
                    'keadaan_umum' => 'Tampak gelisah',
                    'tanda_vital' => 'TD: 140/90, N: 92, S: 37.0',
                ],
                'diagnosis' => 'Gangguan psikotik akut',
                'tindakan' => 'Pemberian obat antipsikotik dan observasi ketat',
            ],
        ]);

        // Form Resume Poliklinik
        Form::create([
            'type' => 'resume_poliklinik',
            'user_id' => $mahasiswa->id,
            'patient_id' => $patients[2]->id,
            'status' => 'approved',
            'data' => [
                'identitas_pasien' => [
                    'nama' => 'Budi Santoso',
                    'umur' => 42,
                    'jenis_kelamin' => 'L',
                    'tanggal_kunjungan' => now()->toIso8601String(),
                ],
                'anamnesis' => [
                    'keluhan' => 'Sulit konsentrasi dan mudah lupa',
                    'riwayat_penyakit' => 'Riwayat depresi 1 tahun yang lalu',
                ],
                'pemeriksaan' => [
                    'fisik' => 'Dalam batas normal',
                    'mental' => 'Mood depresif, konsentrasi menurun',
                ],
                'diagnosis' => 'Episode depresif ringan',
                'terapi' => 'Psikoterapi dan antidepresan',
                'rencana_tindak_lanjut' => 'Kontrol 2 minggu',
            ],
        ]);

        // Form SAP
        Form::create([
            'type' => 'sap',
            'user_id' => $mahasiswa->id,
            'patient_id' => $patients[3]->id,
            'status' => 'submitted',
            'data' => [
                'topik' => 'Manajemen Stres',
                'sasaran' => 'Pasien dan keluarga',
                'waktu' => '45 menit',
                'tempat' => 'Ruang Konseling',
                'tujuan_umum' => 'Meningkatkan pemahaman tentang manajemen stres',
                'tujuan_khusus' => [
                    'Pasien dapat menjelaskan pengertian stres',
                    'Pasien dapat menyebutkan tanda-tanda stres',
                    'Pasien dapat mempraktikkan teknik relaksasi',
                ],
                'materi' => [
                    'Pengertian stres',
                    'Penyebab dan dampak stres',
                    'Teknik manajemen stres',
                    'Latihan relaksasi',
                ],
                'metode' => 'Ceramah, diskusi, dan demonstrasi',
                'media' => 'Leaflet dan video',
                'evaluasi' => 'Pasien mampu mempraktikkan teknik relaksasi dengan baik',
            ],
        ]);

        // Form Catatan Tambahan
        Form::create([
            'type' => 'catatan_tambahan',
            'user_id' => $mahasiswa->id,
            'patient_id' => $patients[4]->id,
            'status' => 'submitted',
            'data' => [
                'tanggal' => now()->toIso8601String(),
                'catatan' => 'Pasien menunjukkan perkembangan positif. Sudah mulai dapat berinteraksi dengan pasien lain. Nafsu makan membaik. Tidur lebih teratur.',
                'tindak_lanjut' => 'Lanjutkan terapi dan observasi perkembangan',
            ],
        ]);
    }
}
