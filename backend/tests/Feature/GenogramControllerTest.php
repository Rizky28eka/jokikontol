<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;
use App\Models\Patient;
use App\Models\Form;

class GenogramControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_render_genogram_svg_for_form()
    {
        $user = User::factory()->create();
        $patient = Patient::factory()->create();

        $form = Form::factory()->create([
            'type' => 'pengkajian',
            'patient_id' => $patient->id,
            'user_id' => $user->id,
        ]);

        // add genogram record
        $form->genogram()->create([
            'structure' => [
                'members' => [ ['id' => 1, 'name' => 'A', 'gender' => 'L'], ['id' => 2, 'name' => 'B', 'gender' => 'P'] ],
                'connections' => [ ['id'=>10, 'from'=>1, 'to'=>2, 'type'=>'marriage'] ]
            ],
            'notes' => 'Sample'
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->get('/api/forms/' . $form->id . '/genogram/svg');

        $response->assertStatus(200);
        $response->assertHeader('Content-Type', 'image/svg+xml');
        $this->assertStringContainsString('<svg', $response->getContent());
    }

    public function test_render_genogram_svg_returns_404_if_missing()
    {
        $user = User::factory()->create();
        $patient = Patient::factory()->create();

        $form = Form::factory()->create([
            'type' => 'pengkajian',
            'patient_id' => $patient->id,
            'user_id' => $user->id,
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->get('/api/forms/' . $form->id . '/genogram/svg');

        $response->assertStatus(404);
    }
}
