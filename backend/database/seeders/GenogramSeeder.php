<?php

namespace Database\Seeders;

use App\Models\Genogram;
use App\Models\Form;
use Illuminate\Database\Seeder;

class GenogramSeeder extends Seeder
{
    public function run(): void
    {
        $forms = Form::where('type', 'pengkajian')->get();

        if ($forms->count() > 0) {
            Genogram::create([
                'form_id' => $forms[0]->id,
            'structure' => [
                'members' => [
                    [
                        'id' => 'member-1',
                        'name' => 'Ahmad Fauzi',
                        'gender' => 'male',
                        'status' => 'alive',
                        'isClient' => true,
                        'generation' => 0,
                        'relationship' => 'Klien',
                    ],
                    [
                        'id' => 'member-2',
                        'name' => 'Bapak Ahmad',
                        'gender' => 'male',
                        'status' => 'alive',
                        'isClient' => false,
                        'generation' => -1,
                        'relationship' => 'Ayah',
                    ],
                    [
                        'id' => 'member-3',
                        'name' => 'Ibu Siti',
                        'gender' => 'female',
                        'status' => 'alive',
                        'isClient' => false,
                        'generation' => -1,
                        'relationship' => 'Ibu',
                    ],
                    [
                        'id' => 'member-4',
                        'name' => 'Rina',
                        'gender' => 'female',
                        'status' => 'alive',
                        'isClient' => false,
                        'generation' => 0,
                        'relationship' => 'Istri',
                    ],
                    [
                        'id' => 'member-5',
                        'name' => 'Andi',
                        'gender' => 'male',
                        'status' => 'alive',
                        'isClient' => false,
                        'generation' => 1,
                        'relationship' => 'Anak',
                    ],
                ],
                'relationships' => [
                    [
                        'from' => 'member-2',
                        'to' => 'member-1',
                        'type' => 'parentChild',
                    ],
                    [
                        'from' => 'member-3',
                        'to' => 'member-1',
                        'type' => 'parentChild',
                    ],
                    [
                        'from' => 'member-2',
                        'to' => 'member-3',
                        'type' => 'marriage',
                    ],
                    [
                        'from' => 'member-1',
                        'to' => 'member-4',
                        'type' => 'marriage',
                    ],
                    [
                        'from' => 'member-1',
                        'to' => 'member-5',
                        'type' => 'parentChild',
                    ],
                ],
            ],
            'notes' => 'Keluarga harmonis, hubungan baik antar anggota keluarga. Dukungan keluarga sangat baik.',
            ]);
        }

        if ($forms->count() > 1) {
            Genogram::create([
                'form_id' => $forms[1]->id,
            'structure' => [
                'members' => [
                    [
                        'id' => 'member-1',
                        'name' => 'Siti Nurhaliza',
                        'gender' => 'female',
                        'status' => 'alive',
                        'isClient' => true,
                        'generation' => 0,
                        'relationship' => 'Klien',
                    ],
                    [
                        'id' => 'member-2',
                        'name' => 'Bapak Hasan',
                        'gender' => 'male',
                        'status' => 'deceased',
                        'isClient' => false,
                        'generation' => -1,
                        'relationship' => 'Ayah',
                    ],
                    [
                        'id' => 'member-3',
                        'name' => 'Ibu Fatimah',
                        'gender' => 'female',
                        'status' => 'alive',
                        'isClient' => false,
                        'generation' => -1,
                        'relationship' => 'Ibu',
                    ],
                    [
                        'id' => 'member-4',
                        'name' => 'Aisyah',
                        'gender' => 'female',
                        'status' => 'alive',
                        'isClient' => false,
                        'generation' => 0,
                        'relationship' => 'Kakak',
                    ],
                ],
                'relationships' => [
                    [
                        'from' => 'member-2',
                        'to' => 'member-1',
                        'type' => 'parentChild',
                    ],
                    [
                        'from' => 'member-3',
                        'to' => 'member-1',
                        'type' => 'parentChild',
                    ],
                    [
                        'from' => 'member-2',
                        'to' => 'member-3',
                        'type' => 'marriage',
                    ],
                    [
                        'from' => 'member-4',
                        'to' => 'member-1',
                        'type' => 'sibling',
                    ],
                ],
            ],
            'notes' => 'Ayah meninggal 2 tahun lalu. Pasien tinggal bersama ibu dan kakak. Dukungan keluarga cukup baik.',
            ]);
        }
    }
}
