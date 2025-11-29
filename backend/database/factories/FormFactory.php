<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use App\Models\Form;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Form>
 */
class FormFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'type' => fake()->randomElement(['pengkajian', 'resume_kegawatdaruratan']),
            'user_id' => 1,
            'patient_id' => 1,
            'status' => fake()->randomElement(['draft', 'submitted', 'revised', 'approved']),
            'data' => [],
        ];
    }
}