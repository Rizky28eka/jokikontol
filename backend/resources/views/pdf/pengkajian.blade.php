@extends('pdf.layout')

@section('content')
<div class="section">
    <div class="section-title">Section 1: Identitas Klien</div>
    @if(isset($data['section_1']))
        @php
        $section1 = $data['section_1'];
        @endphp
        <div class="field-row">
            <span class="field-label">Nama Lengkap:</span>
            <span class="field-value">{{ $section1['nama_lengkap'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Umur:</span>
            <span class="field-value">{{ $section1['umur'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Jenis Kelamin:</span>
            <span class="field-value">{{ $section1['jenis_kelamin'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Status Perkawinan:</span>
            <span class="field-value">{{ $section1['status_perkawinan'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Section 2: Riwayat Kehidupan</div>
    @if(isset($data['section_2']))
        @php
        $section2 = $data['section_2'];
        @endphp
        <div class="field-row">
            <span class="field-label">Riwayat Pendidikan:</span>
            <span class="field-value">{{ $section2['riwayat_pendidikan'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Pekerjaan:</span>
            <span class="field-value">{{ $section2['pekerjaan'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Riwayat Keluarga:</span>
            <span class="field-value">{{ $section2['riwayat_keluarga'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Section 3: Riwayat Psikososial</div>
    @if(isset($data['section_3']))
        @php
        $section3 = $data['section_3'];
        @endphp
        <div class="field-row">
            <span class="field-label">Hubungan Sosial:</span>
            <span class="field-value">{{ $section3['hubungan_sosial'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Dukungan Sosial:</span>
            <span class="field-value">{{ $section3['dukungan_sosial'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Stresor Psikososial:</span>
            <span class="field-value">{{ $section3['stresor_psikososial'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Section 4: Riwayat Psikiatri</div>
    @if(isset($data['section_4']))
        @php
        $section4 = $data['section_4'];
        @endphp
        <div class="field-row">
            <span class="field-label">Riwayat Gangguan Psikiatri:</span>
            <span class="field-value">{{ $section4['riwayat_gangguan_psikiatri'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Section 10: Renpra (Rencana Perawatan)</div>
    @if(isset($data['section_10']))
        @php
        $section10 = $data['section_10'];
        @endphp
        <div class="field-row">
            <span class="field-label">Diagnosis:</span>
            <span class="field-value">{{ $section10['diagnosis'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Tujuan:</span>
            <span class="field-value">{{ $section10['tujuan'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Kriteria:</span>
            <span class="field-value">{{ $section10['kriteria'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Rasional:</span>
            <span class="field-value">{{ $section10['rasional'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

{{--
<!-- If genogram exists, it could be included here -->
@if($form->genogram)
<div class="section">
    <div class="section-title">Genogram</div>
    <img src="data:image/svg+xml;base64,{{ base64_encode($form->genogram->structure) }}" alt="Genogram" style="width: 100%; height: auto;">
</div>
@endif
--}}
@endsection