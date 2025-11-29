<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use App\Models\Patient;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Patient>
 */
class PatientFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'name' => fake()->name(),
            'age' => fake()->numberBetween(18, 80),
            'gender' => fake()->randomElement(['L', 'P']), // L for Laki-laki (Male), P for Perempuan (Female)
            'address' => fake()->address(),
            'rm_number' => fake()->unique()->numerify('RM#####'),
            'created_by' => 1, // Default user ID
        ];
    }
}