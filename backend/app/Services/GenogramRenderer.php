<?php

namespace App\Services;

class GenogramRenderer
{
    public static function renderSvgFromStructure($structure): string
    {
        $members = $structure['members'] ?? [];
        $connections = $structure['connections'] ?? [];

        $nodeRadius = 24;
        $hSpacing = 140;
        $v = 60;
        $width = max(300, (count($members) * $hSpacing) + 80);
        $height = 260;

        $svgParts = [];
        $svgParts[] = "<svg xmlns='http://www.w3.org/2000/svg' width='$width' height='$height' viewBox='0 0 $width $height'>";
        $svgParts[] = "<style>text { font-family: Arial, Helvetica, sans-serif; font-size: 12px; }</style>";

        // positions
        $positions = [];
        for ($i = 0; $i < count($members); $i++) {
            $m = $members[$i];
            $x = 60 + $i * $hSpacing;
            $y = $v + 40 * (($m['gender'] ?? 'L') === 'P' ? 1 : 0);
            $positions[$m['id']] = ['x' => $x, 'y' => $y];
            $name = htmlspecialchars(substr($m['name'], 0, 20));
            $svgParts[] = "<circle cx='{$x}' cy='{$y}' r='{$nodeRadius}' fill='lightblue' stroke='black'/>";
            $svgParts[] = "<text x='{$x}' y='{$y}' text-anchor='middle' dominant-baseline='central'>{$name}</text>";
        }

        foreach ($connections as $conn) {
            $from = $conn['from'];
            $to = $conn['to'];
            if (!isset($positions[$from]) || !isset($positions[$to])) continue;
            $a = $positions[$from];
            $b = $positions[$to];
            $svgParts[] = "<line x1='{$a['x']}' y1='{$a['y']}' x2='{$b['x']}' y2='{$b['y']}' stroke='black' stroke-width='2'/>";
        }

        $svgParts[] = "</svg>";
        return implode('', $svgParts);
    }
}
