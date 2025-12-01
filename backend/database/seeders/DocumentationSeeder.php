<?php

namespace Database\Seeders;

use App\Models\Documentation;
use App\Models\Form;
use Illuminate\Database\Seeder;

class DocumentationSeeder extends Seeder
{
    public function run(): void
    {
        $forms = Form::where('type', 'sap')->get();

        if ($forms->count() > 0) {
            Documentation::create([
                'form_id' => $forms[0]->id,
                'file_path' => 'documentations/materi_manajemen_stres.pdf',
                'type' => 'materi',
            ]);

            Documentation::create([
                'form_id' => $forms[0]->id,
                'file_path' => 'documentations/foto_penyuluhan_1.jpg',
                'type' => 'foto',
            ]);
        }

        $pengkajianForms = Form::where('type', 'pengkajian')->get();
        if ($pengkajianForms->count() > 0) {
            Documentation::create([
                'form_id' => $pengkajianForms[0]->id,
                'file_path' => 'documentations/foto_pasien_1.jpg',
                'type' => 'foto',
            ]);
        }
    }
}
