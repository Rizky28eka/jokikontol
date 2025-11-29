@extends('pdf.layout')

@section('content')
<div class="section">
    <div class="section-title">Resume Kegawatdaruratan - Identitas</div>
    @if(isset($data['identitas']))
        @php
        $identitas = $data['identitas'];
        @endphp
        <div class="field-row">
            <span class="field-label">Nama Lengkap:</span>
            <span class="field-value">{{ $identitas['nama_lengkap'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Umur:</span>
            <span class="field-value">{{ $identitas['umur'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Jenis Kelamin:</span>
            <span class="field-value">{{ $identitas['jenis_kelamin'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Alamat:</span>
            <span class="field-value">{{ $identitas['alamat'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Tanggal Masuk:</span>
            <span class="field-value">{{ $identitas['tanggal_masuk'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Riwayat Keluhan Utama</div>
    @if(isset($data['riwayat_keluhan']))
        @php
        $riwayat = $data['riwayat_keluhan'];
        @endphp
        <div class="field-row">
            <span class="field-label">Keluhan Utama:</span>
            <span class="field-value">{{ $riwayat['keluhan_utama'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Riwayat Penyakit Sekarang:</span>
            <span class="field-value">{{ $riwayat['riwayat_penyakit_sekarang'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Faktor Pencetus:</span>
            <span class="field-value">{{ $riwayat['faktor_pencetus'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Pemeriksaan Fisik</div>
    @if(isset($data['pemeriksaan_fisik']))
        @php
        $fisik = $data['pemeriksaan_fisik'];
        @endphp
        <div class="field-row">
            <span class="field-label">Keadaan Umum:</span>
            <span class="field-value">{{ $fisik['keadaan_umum'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Tanda-tanda Vital:</span>
            <span class="field-value">{{ $fisik['tanda_vital'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Pemeriksaan Lain:</span>
            <span class="field-value">{{ $fisik['pemeriksaan_lain'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Status Mental</div>
    @if(isset($data['status_mental']))
        @php
        $mental = $data['status_mental'];
        @endphp
        <div class="field-row">
            <span class="field-label">Kesadaran:</span>
            <span class="field-value">{{ $mental['kesadaran'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Orientasi:</span>
            <span class="field-value">{{ $mental['orientasi'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Bentuk Pemikiran:</span>
            <span class="field-value">{{ $mental['bentuk_pemikiran'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Isi Pemikiran:</span>
            <span class="field-value">{{ $mental['isi_pemikiran'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Persepsi:</span>
            <span class="field-value">{{ $mental['persepsi'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Diagnosis</div>
    @if(isset($data['diagnosis']))
        @php
        $diagnosis = $data['diagnosis'];
        @endphp
        <div class="field-row">
            <span class="field-label">Diagnosis Utama:</span>
            <span class="field-value">{{ $diagnosis['diagnosis_utama'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Diagnosis Banding:</span>
            <span class="field-value">{{ $diagnosis['diagnosis_banding'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Diagnosis Tambahan:</span>
            <span class="field-value">{{ $diagnosis['diagnosis_tambahan'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Tindakan yang Telah Dilakukan</div>
    @if(isset($data['tindakan']))
        @php
        $tindakan = $data['tindakan'];
        @endphp
        <div class="field-row">
            <span class="field-label">Tindakan Medis:</span>
            <span class="field-value">{{ $tindakan['tindakan_medis'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Tindakan Keperawatan:</span>
            <span class="field-value">{{ $tindakan['tindakan_keperawatan'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Terapi Psikososial:</span>
            <span class="field-value">{{ $tindakan['terapi_psikososial'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Implementasi</div>
    @if(isset($data['implementasi']))
        @php
        $implementasi = $data['implementasi'];
        @endphp
        <div class="field-row">
            <span class="field-label">Pelaksanaan Intervensi:</span>
            <span class="field-value">{{ $implementasi['pelaksanaan_intervensi'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Kolaborasi dengan Tim:</span>
            <span class="field-value">{{ $implementasi['kolaborasi_tim'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Edukasi:</span>
            <span class="field-value">{{ $implementasi['edukasi'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Evaluasi</div>
    @if(isset($data['evaluasi']))
        @php
        $evaluasi = $data['evaluasi'];
        @endphp
        <div class="field-row">
            <span class="field-label">Respon terhadap Intervensi:</span>
            <span class="field-value">{{ $evaluasi['respon_intervensi'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Perubahan Klinis:</span>
            <span class="field-value">{{ $evaluasi['perubahan_klinis'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Tujuan yang Telah Tercapai:</span>
            <span class="field-value">{{ $evaluasi['tujuan_tercapai'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Hambatan dalam Perawatan:</span>
            <span class="field-value">{{ $evaluasi['hambatan_perawatan'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Rencana Tindak Lanjut</div>
    @if(isset($data['rencana_lanjut']))
        @php
        $lanjut = $data['rencana_lanjut'];
        @endphp
        <div class="field-row">
            <span class="field-label">Rencana Medis Lanjutan:</span>
            <span class="field-value">{{ $lanjut['rencana_medis'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Rencana Keperawatan Lanjutan:</span>
            <span class="field-value">{{ $lanjut['rencana_keperawatan'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Rencana Pemantauan:</span>
            <span class="field-value">{{ $lanjut['rencana_pemantauan'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Rencana dengan Keluarga</div>
    @if(isset($data['rencana_keluarga']))
        @php
        $keluarga = $data['rencana_keluarga'];
        @endphp
        <div class="field-row">
            <span class="field-label">Keterlibatan Keluarga:</span>
            <span class="field-value">{{ $keluarga['keterlibatan_keluarga'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Edukasi untuk Keluarga:</span>
            <span class="field-value">{{ $keluarga['edukasi_keluarga'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Dukungan dari Keluarga:</span>
            <span class="field-value">{{ $keluarga['dukungan_keluarga'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Renpra (Rencana Perawatan)</div>
    @if(isset($data['renpra']))
        @php
        $renpra = $data['renpra'];
        @endphp
        <div class="field-row">
            <span class="field-label">Diagnosis:</span>
            <span class="field-value">{{ $renpra['diagnosis'] ?? '-' }}</span>
        </div>
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
        <div class="field-row">
            <span class="field-label">Evaluasi:</span>
            <span class="field-value">{{ $renpra['evaluasi'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>
@endsection