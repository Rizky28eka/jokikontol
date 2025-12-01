<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call([
            UserSeeder::class,
            PatientSeeder::class,
            FormSeeder::class,
            NursingDiagnosisSeeder::class,
            NursingInterventionSeeder::class,
            GenogramSeeder::class,
            RevisionSeeder::class,
            DocumentationSeeder::class,
        ]);
    }
}
