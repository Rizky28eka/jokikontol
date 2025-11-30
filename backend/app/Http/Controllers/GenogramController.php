<?php

namespace App\Http\Controllers;

use App\Services\GenogramRenderer;

use App\Models\Form;
use Illuminate\Http\Request;

class GenogramController extends Controller
{
    /**
     * Render a simple SVG from a form's genogram structure.
     */
    public function render(Request $request, Form $form)
    {
        // permission check
        if ($form->user_id !== $request->user()->id && $request->user()->role !== 'dosen') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if (!$form->genogram || !$form->genogram->structure) {
            return response()->json(['message' => 'No genogram available'], 404);
        }

        $structure = $form->genogram->structure;
        $svg = GenogramRenderer::renderSvgFromStructure($structure);

        return response($svg, 200, ['Content-Type' => 'image/svg+xml']);
    }
}
