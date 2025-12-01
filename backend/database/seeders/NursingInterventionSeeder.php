<?php

namespace Database\Seeders;

use App\Models\NursingIntervention;
use App\Models\User;
use Illuminate\Database\Seeder;

class NursingInterventionSeeder extends Seeder
{
    public function run(): void
    {
        $mahasiswa = User::where('role', 'mahasiswa')->first();

        NursingIntervention::create([
            'name' => 'Teknik Relaksasi Napas Dalam',
            'description' => 'Mengajarkan pasien teknik pernapasan untuk mengurangi kecemasan',
            'created_by' => $mahasiswa->id,
        ]);

        NursingIntervention::create([
            'name' => 'Terapi Aktivitas Kelompok (TAK)',
            'description' => 'Melibatkan pasien dalam aktivitas kelompok untuk meningkatkan sosialisasi',
            'created_by' => $mahasiswa->id,
        ]);

        NursingIntervention::create([
            'name' => 'Strategi Pelaksanaan (SP) Halusinasi',
            'description' => 'Mengajarkan 4 cara mengontrol halusinasi: menghardik, bercakap-cakap, aktivitas, minum obat',
            'created_by' => $mahasiswa->id,
        ]);

        NursingIntervention::create([
            'name' => 'Orientasi Realitas',
            'description' => 'Membantu pasien mengenali waktu, tempat, dan orang di sekitarnya',
            'created_by' => $mahasiswa->id,
        ]);

        NursingIntervention::create([
            'name' => 'Terapi Kognitif Perilaku',
            'description' => 'Membantu pasien mengidentifikasi dan mengubah pola pikir negatif',
            'created_by' => $mahasiswa->id,
        ]);

        NursingIntervention::create([
            'name' => 'Manajemen Kemarahan',
            'description' => 'Mengajarkan pasien cara mengendalikan emosi dan kemarahan',
            'created_by' => $mahasiswa->id,
        ]);
    }
}
