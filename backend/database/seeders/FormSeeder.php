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
                // Section 1: Identitas Klien
                'nama_lengkap' => 'Ahmad Fauzi',
                'umur' => '35',
                'jenis_kelamin' => 'L',
                'status_perkawinan' => 'menikah',
                
                // Section 2: Riwayat Kehidupan
                'riwayat_pendidikan' => 'S1 Teknik Informatika, lulus tahun 2012 dari Universitas Indonesia',
                'pekerjaan' => 'Software Engineer di PT. Technology Solutions',
                'riwayat_keluarga' => 'Anak kedua dari tiga bersaudara. Ayah pensiunan PNS, ibu ibu rumah tangga. Hubungan keluarga harmonis.',
                
                // Section 3: Riwayat Psikososial
                'hubungan_sosial' => 'Baik dengan keluarga dan teman, aktif dalam komunitas teknologi',
                'dukungan_sosial' => 'Mendapat dukungan penuh dari istri dan keluarga. Teman kerja juga supportif.',
                'stresor_psikososial' => 'Tekanan deadline proyek yang ketat, beban kerja yang tinggi',
                
                // Section 4: Riwayat Psikiatri
                'riwayat_gangguan_psikiatri' => 'Tidak ada riwayat gangguan psikiatri sebelumnya. Baru pertama kali mengalami keluhan psikologis.',
                
                // Section 5: Pemeriksaan Psikologis
                'kesadaran' => 'sadar_penuh',
                'orientasi' => 'utuh',
                'penampilan' => 'Rapi, berpakaian sesuai, ekspresi wajah tampak cemas',
                
                // Section 6: Fungsi Psikologis
                'mood' => 'ansietas',
                'afect' => 'labil',
                'alam_pikiran' => 'Koheren, tidak ada flight of ideas, namun konten pikiran banyak berisi kekhawatiran',
                
                // Section 7: Fungsi Sosial
                'fungsi_sosial' => 'Masih mampu menjalankan fungsi sosial dengan baik. Tetap berinteraksi dengan keluarga dan rekan kerja.',
                
                // Section 8: Fungsi Spiritual
                'kepercayaan' => 'Islam',
                'praktik_ibadah' => 'Sholat 5 waktu, namun akhir-akhir ini kadang terlewat karena sulit konsentrasi',
                
                // Section 9: Genogram
                'genogram_structure' => [
                    'members' => [
                        ['id' => 1, 'name' => 'Ayah', 'gender' => 'M', 'age' => 65, 'status' => 'alive'],
                        ['id' => 2, 'name' => 'Ibu', 'gender' => 'F', 'age' => 62, 'status' => 'alive'],
                        ['id' => 3, 'name' => 'Kakak', 'gender' => 'M', 'age' => 38, 'status' => 'alive'],
                        ['id' => 4, 'name' => 'Ahmad Fauzi', 'gender' => 'M', 'age' => 35, 'status' => 'alive'],
                        ['id' => 5, 'name' => 'Adik', 'gender' => 'F', 'age' => 30, 'status' => 'alive'],
                        ['id' => 6, 'name' => 'Istri', 'gender' => 'F', 'age' => 33, 'status' => 'alive'],
                    ],
                    'connections' => [
                        ['from' => 1, 'to' => 2, 'type' => 'married'],
                        ['from' => 1, 'to' => 3, 'type' => 'parent'],
                        ['from' => 1, 'to' => 4, 'type' => 'parent'],
                        ['from' => 1, 'to' => 5, 'type' => 'parent'],
                        ['from' => 4, 'to' => 6, 'type' => 'married'],
                    ],
                ],
                'genogram_notes' => 'Pasien adalah anak kedua dari tiga bersaudara. Ayah pensiunan, ibu IRT. Pasien sudah menikah sejak 5 tahun yang lalu dan belum memiliki anak.',
                
                // Section 10: Rencana Perawatan (Renpra)
                'diagnosis' => 1, // Gangguan Kecemasan
                'intervensi' => [1, 2, 3], // Array of intervention IDs
                'tujuan' => 'Pasien mampu mengelola kecemasan dengan teknik relaksasi dan cognitive reframing dalam 2 minggu',
                'kriteria' => 'Pasien melaporkan penurunan tingkat kecemasan dari skala 8/10 menjadi 4/10, mampu tidur 6-7 jam per malam',
                'rasional' => 'Intervensi kognitif-behavioral efektif untuk mengatasi gangguan kecemasan menyeluruh',
                
                // Section 11: Penutup
                'catatan_tambahan' => 'Pasien kooperatif selama pemeriksaan. Motivasi untuk sembuh tinggi. Disarankan untuk follow-up mingguan.',
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
                'nama_lengkap' => 'Siti Nurhaliza',
                'umur' => 28,
                'jenis_kelamin' => 'Perempuan',
                'alamat' => 'Jl. Sudirman No. 45, Bandung',
                'tanggal_masuk' => now()->toIso8601String(),
                'keluhan_utama' => 'Halusinasi pendengaran',
                'riwayat_penyakit_sekarang' => 'Pasien mendengar suara-suara sejak 2 hari yang lalu',
                'faktor_pencetus' => 'Stres pekerjaan',
                'keadaan_umum' => 'Tampak gelisah',
                'tanda_vital' => 'TD: 140/90, N: 92, S: 37.0',
                'pemeriksaan_lain' => 'Tidak ada kelainan fisik',
                'kesadaran' => 'Compos mentis',
                'orientasi' => 'Baik',
                'bentuk_pemikiran' => 'Non realistik',
                'isi_pemikiran' => 'Waham kejar',
                'persepsi' => 'Halusinasi auditorik',
                'diagnosis_utama' => 'Gangguan psikotik akut',
                'diagnosis_banding' => 'Skizofrenia',
                'diagnosis_tambahan' => '-',
                'tindakan_medis' => 'Pemberian obat antipsikotik',
                'tindakan_keperawatan' => 'Observasi ketat dan isolasi',
                'terapi_psikososial' => 'Terapi suportif',
                'renpra_diagnosis' => 'Gangguan persepsi sensori: halusinasi',
                'renpra_intervensi' => 'Monitor halusinasi, ajarkan teknik distraksi',
                'renpra_tujuan' => 'Pasien dapat mengontrol halusinasi',
                'renpra_kriteria' => 'Frekuensi halusinasi berkurang',
                'renpra_rasional' => 'Meningkatkan kemampuan pasien mengendalikan halusinasi',
            ],
        ]);

        // Form Resume Poliklinik
        Form::create([
            'type' => 'resume_poliklinik',
            'user_id' => $mahasiswa->id,
            'patient_id' => $patients[2]->id,
            'status' => 'approved',
            'data' => [
                'nama_lengkap' => 'Budi Santoso',
                'umur' => 42,
                'jenis_kelamin' => 'Laki-laki',
                'status_perkawinan' => 'Menikah',
                'riwayat_pendidikan' => 'S1 Ekonomi',
                'pekerjaan' => 'Manajer',
                'riwayat_keluarga' => 'Ayah riwayat depresi',
                'hubungan_sosial' => 'Cukup baik',
                'dukungan_sosial' => 'Keluarga mendukung',
                'stresor_psikososial' => 'Tekanan pekerjaan tinggi',
                'riwayat_gangguan_psikiatri' => 'Riwayat depresi 1 tahun yang lalu',
                'riwayat_pengobatan' => 'Pernah konsumsi antidepresan',
                'kesadaran' => 'Compos mentis',
                'orientasi' => 'Baik',
                'penampilan' => 'Rapi',
                'mood' => 'Depresif',
                'afect' => 'Tumpul',
                'alam_pikiran' => 'Pesimis',
                'fungsi_sosial' => 'Menurun',
                'interaksi_sosial' => 'Menarik diri',
                'kepercayaan' => 'Islam',
                'praktik_ibadah' => 'Jarang',
                'diagnosis' => 'Episode depresif ringan',
                'intervensi' => 'Psikoterapi dan farmakologi',
                'tujuan' => 'Perbaikan mood dan fungsi sosial',
                'kriteria' => 'Mood membaik, aktivitas meningkat',
                'rasional' => 'Kombinasi terapi efektif untuk depresi',
                'catatan_tambahan' => 'Kontrol 2 minggu',
                'tanggal_pengisian' => now()->toIso8601String(),
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
                'sub_topik' => 'Teknik Relaksasi',
                'sasaran' => 'Pasien dan keluarga',
                'tanggal_pelaksanaan' => now()->toIso8601String(),
                'waktu_pelaksanaan' => '09:00 - 09:45',
                'tempat' => 'Ruang Konseling',
                'durasi' => '45 menit',
                'tujuan_umum' => 'Meningkatkan pemahaman tentang manajemen stres',
                'tujuan_khusus' => 'Pasien dapat menjelaskan pengertian stres, menyebutkan tanda-tanda stres, dan mempraktikkan teknik relaksasi',
                'materi_penyuluhan' => 'Pengertian stres, penyebab dan dampak stres, teknik manajemen stres, latihan relaksasi',
                'metode' => ['Ceramah', 'Diskusi', 'Demonstrasi'],
                'media' => ['Leaflet', 'Video'],
                'kegiatan' => [
                    ['tahap' => 'Pembukaan', 'kegiatan_penyuluh' => 'Salam dan perkenalan', 'kegiatan_peserta' => 'Menjawab salam', 'waktu' => '5 menit'],
                    ['tahap' => 'Inti', 'kegiatan_penyuluh' => 'Menjelaskan materi', 'kegiatan_peserta' => 'Mendengarkan dan bertanya', 'waktu' => '30 menit'],
                    ['tahap' => 'Penutup', 'kegiatan_penyuluh' => 'Evaluasi dan kesimpulan', 'kegiatan_peserta' => 'Menjawab pertanyaan', 'waktu' => '10 menit'],
                ],
                'evaluasi_struktur' => 'Persiapan materi lengkap',
                'evaluasi_proses' => 'Peserta aktif bertanya',
                'evaluasi_hasil' => 'Pasien mampu mempraktikkan teknik relaksasi dengan baik',
                'penyuluh' => 'Mahasiswa Keperawatan',
                'moderator' => 'Tim Keperawatan',
                'fasilitator' => 'Perawat Senior',
                'renpra_diagnosis' => 'Ansietas',
                'renpra_intervensi' => 'Edukasi manajemen stres',
                'renpra_tujuan' => 'Pasien mampu mengelola stres',
                'renpra_kriteria' => 'Tingkat stres berkurang',
                'renpra_rasional' => 'Edukasi meningkatkan kemampuan koping',
            ],
        ]);

        // Form Catatan Tambahan
        Form::create([
            'type' => 'catatan_tambahan',
            'user_id' => $mahasiswa->id,
            'patient_id' => $patients[4]->id,
            'status' => 'submitted',
            'data' => [
                'tanggal_catatan' => now()->toIso8601String(),
                'waktu_catatan' => now()->format('H:i'),
                'kategori' => 'Perkembangan',
                'catatan' => 'Pasien menunjukkan perkembangan positif. Sudah mulai dapat berinteraksi dengan pasien lain. Nafsu makan membaik. Tidur lebih teratur.',
                'tindak_lanjut' => 'Lanjutkan terapi dan observasi perkembangan',
            ],
        ]);
    }
}
