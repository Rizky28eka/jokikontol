@extends('pdf.layout')

@section('content')
<div class="section">
    <div class="section-title">Catatan Tambahan</div>
    @if(isset($data['catatan']))
        @php
        $catatan = $data['catatan'];
        @endphp
        <div class="field-row">
            <span class="field-label">Isi Catatan:</span>
            <span class="field-value">{{ $catatan['isi_catatan'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    @if(isset($data['catatan']['renpra']))
        <div class="section-title">Renpra (Rencana Perawatan) - Opsional</div>
        @php
        $renpra = $data['catatan']['renpra'];
        @endphp
        <div class="field-row">
            <span class="field-label">Diagnosis:</span>
            <span class="field-value">{{ $renpra['diagnosis'] ?? '-' }}</span>
        </div>
        @if(isset($renpra['intervensi']) && is_array($renpra['intervensi']))
        <div class="field-row">
            <span class="field-label">Intervensi:</span>
            <span class="field-value">{{ implode(', ', $renpra['intervensi']) }}</span>
        </div>
        @endif
        <div class="field-row">
            <span class="field-label">Tujuan:</span>
            <span class="field-value">{{ $renpra['tujuan'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Kriteria:</span>
            <span class="field-value">{{ $renpra['kriteria'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Rasional:</span>
            <span class="field-value">{{ $renpra['rasional'] ?? '-' }}</span>
        </div>
    @else
        <p>Renpra tidak diisi</p>
    @endif
</div>
@endsection