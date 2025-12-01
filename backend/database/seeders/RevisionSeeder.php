<?php

namespace Database\Seeders;

use App\Models\Revision;
use App\Models\Form;
use App\Models\User;
use Illuminate\Database\Seeder;

class RevisionSeeder extends Seeder
{
    public function run(): void
    {
        $dosen = User::where('role', 'dosen')->first();
        $forms = Form::where('status', 'submitted')->get();

        if ($forms->count() > 0) {
            Revision::create([
                'form_id' => $forms[0]->id,
                'reviewed_by' => $dosen->id,
                'comment' => 'Mohon lengkapi data pemeriksaan fisik dengan lebih detail, terutama pada bagian pemeriksaan neurologis.',
            ]);
        }

        if ($forms->count() > 1) {
            Revision::create([
                'form_id' => $forms[1]->id,
                'reviewed_by' => $dosen->id,
                'comment' => 'Diagnosis sudah tepat. Namun perlu ditambahkan rencana tindak lanjut yang lebih spesifik.',
            ]);
        }
    }
}
