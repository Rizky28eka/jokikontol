@extends('pdf.layout')

@section('content')
<div class="section">
    <div class="section-title">Resume Poliklinik - Identitas Klien</div>
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
    <div class="section-title">Riwayat Kehidupan</div>
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
    <div class="section-title">Riwayat Psikososial</div>
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
    <div class="section-title">Riwayat Psikiatri</div>
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
    <div class="section-title">Pemeriksaan Psikologis</div>
    @if(isset($data['section_5']))
        @php
        $section5 = $data['section_5'];
        @endphp
        <div class="field-row">
            <span class="field-label">Kesadaran:</span>
            <span class="field-value">{{ $section5['kesadaran'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Orientasi:</span>
            <span class="field-value">{{ $section5['orientasi'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Penampilan:</span>
            <span class="field-value">{{ $section5['penampilan'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Fungsi Psikologis</div>
    @if(isset($data['section_6']))
        @php
        $section6 = $data['section_6'];
        @endphp
        <div class="field-row">
            <span class="field-label">Mood:</span>
            <span class="field-value">{{ $section6['mood'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Afect:</span>
            <span class="field-value">{{ $section6['afect'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Alam pikiran:</span>
            <span class="field-value">{{ $section6['alam_pikiran'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Fungsi Sosial</div>
    @if(isset($data['section_7']))
        @php
        $section7 = $data['section_7'];
        @endphp
        <div class="field-row">
            <span class="field-label">Fungsi Sosial:</span>
            <span class="field-value">{{ $section7['fungsi_sosial'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Fungsi Spiritual</div>
    @if(isset($data['section_8']))
        @php
        $section8 = $data['section_8'];
        @endphp
        <div class="field-row">
            <span class="field-label">Kepercayaan:</span>
            <span class="field-value">{{ $section8['kepercayaan'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Praktik Ibadah:</span>
            <span class="field-value">{{ $section8['praktik_ibadah'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Renpra (Rencana Perawatan)</div>
    @if(isset($data['section_9']))
        @php
        $section9 = $data['section_9'];
        @endphp
        <div class="field-row">
            <span class="field-label">Diagnosis:</span>
            <span class="field-value">{{ $section9['diagnosis'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Tujuan:</span>
            <span class="field-value">{{ $section9['tujuan'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Kriteria:</span>
            <span class="field-value">{{ $section9['kriteria'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Rasional:</span>
            <span class="field-value">{{ $section9['rasional'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Penutup</div>
    @if(isset($data['section_10']))
        @php
        $section10 = $data['section_10'];
        @endphp
        <div class="field-row">
            <span class="field-label">Catatan Tambahan:</span>
            <span class="field-value">{{ $section10['catatan_tambahan'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Tanggal Pengisian:</span>
            <span class="field-value">{{ $section10['tanggal_pengisian'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>
@endsection