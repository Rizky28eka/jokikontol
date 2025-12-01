<?php

namespace Database\Seeders;

use App\Models\Patient;
use App\Models\User;
use Illuminate\Database\Seeder;

class PatientSeeder extends Seeder
{
    public function run(): void
    {
        $mahasiswa = User::where('role', 'mahasiswa')->first();

        Patient::create([
            'name' => 'Ahmad Fauzi',
            'rm_number' => 'RM001',
            'gender' => 'L',
            'age' => 35,
            'address' => 'Jl. Merdeka No. 123, Jakarta Pusat',
            'created_by' => $mahasiswa->id,
        ]);

        Patient::create([
            'name' => 'Siti Nurhaliza',
            'rm_number' => 'RM002',
            'gender' => 'P',
            'age' => 28,
            'address' => 'Jl. Sudirman No. 45, Bandung',
            'created_by' => $mahasiswa->id,
        ]);

        Patient::create([
            'name' => 'Budi Santoso',
            'rm_number' => 'RM003',
            'gender' => 'L',
            'age' => 42,
            'address' => 'Jl. Gatot Subroto No. 78, Surabaya',
            'created_by' => $mahasiswa->id,
        ]);

        Patient::create([
            'name' => 'Dewi Lestari',
            'rm_number' => 'RM004',
            'gender' => 'P',
            'age' => 31,
            'address' => 'Jl. Ahmad Yani No. 90, Yogyakarta',
            'created_by' => $mahasiswa->id,
        ]);

        Patient::create([
            'name' => 'Eko Prasetyo',
            'rm_number' => 'RM005',
            'gender' => 'L',
            'age' => 25,
            'address' => 'Jl. Diponegoro No. 12, Semarang',
            'created_by' => $mahasiswa->id,
        ]);
    }
}
