@extends('pdf.layout')

@section('content')
<div class="section">
    <div class="section-title">Satuan Acara Penyuluhan - Identitas Kegiatan</div>
    @if(isset($data['identitas']))
        @php
        $identitas = $data['identitas'];
        @endphp
        <div class="field-row">
            <span class="field-label">Topik:</span>
            <span class="field-value">{{ $identitas['topik'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Sasaran:</span>
            <span class="field-value">{{ $identitas['sasaran'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Waktu:</span>
            <span class="field-value">{{ $identitas['waktu'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Tempat:</span>
            <span class="field-value">{{ $identitas['tempat'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Tujuan</div>
    @if(isset($data['tujuan']))
        @php
        $tujuan = $data['tujuan'];
        @endphp
        <div class="field-row">
            <span class="field-label">Tujuan Umum:</span>
            <span class="field-value">{{ $tujuan['umum'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Tujuan Khusus:</span>
            <span class="field-value">{{ $tujuan['khusus'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Materi dan Metode</div>
    @if(isset($data['materi_dan_metode']))
        @php
        $materi = $data['materi_dan_metode'];
        @endphp
        <div class="field-row">
            <span class="field-label">Materi:</span>
            <span class="field-value">{{ $materi['materi'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Metode:</span>
            <span class="field-value">{{ $materi['metode'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Joblist Kegiatan</div>
    @if(isset($data['joblist']))
        @php
        $joblist = $data['joblist'];
        @endphp
        @if(isset($joblist['roles']) && is_array($joblist['roles']))
            @foreach($joblist['roles'] as $role)
                <div class="field-row">
                    <span class="field-label">Role:</span>
                    <span class="field-value">{{ $role }}</span>
                </div>
            @endforeach
        @else
            <p>No roles specified</p>
        @endif
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Pengorganisasian</div>
    @if(isset($data['pengorganisasian']))
        @php
        $organisasi = $data['pengorganisasian'];
        @endphp
        <div class="field-row">
            <span class="field-label">Nama Penyuluh:</span>
            <span class="field-value">{{ $organisasi['penyuluh'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Nama Moderator:</span>
            <span class="field-value">{{ $organisasi['moderator'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Nama Fasilitator:</span>
            <span class="field-value">{{ $organisasi['fasilitator'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Nama Time Keeper:</span>
            <span class="field-value">{{ $organisasi['time_keeper'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Nama Dokumentator:</span>
            <span class="field-value">{{ $organisasi['dokumentator'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Nama Observer:</span>
            <span class="field-value">{{ $organisasi['observer'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Tabel Kegiatan</div>
    @if(isset($data['tabel_kegiatan']) && is_array($data['tabel_kegiatan']))
        <table>
            <thead>
                <tr>
                    <th>Tahap</th>
                    <th>Waktu</th>
                    <th>Kegiatan Penyuluh</th>
                    <th>Kegiatan Peserta</th>
                </tr>
            </thead>
            <tbody>
                @foreach($data['tabel_kegiatan'] as $kegiatan)
                    <tr>
                        <td>{{ $kegiatan['tahap'] ?? '-' }}</td>
                        <td>{{ $kegiatan['waktu'] ?? '-' }}</td>
                        <td>{{ $kegiatan['kegiatan_penyuluh'] ?? '-' }}</td>
                        <td>{{ $kegiatan['kegiatan_peserta'] ?? '-' }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
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
            <span class="field-label">Evaluasi Input:</span>
            <span class="field-value">{{ $evaluasi['input'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Evaluasi Proses:</span>
            <span class="field-value">{{ $evaluasi['proses'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Evaluasi Hasil:</span>
            <span class="field-value">{{ $evaluasi['hasil'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Pertanyaan & Saran Peserta</div>
    @if(isset($data['feedback']))
        @php
        $feedback = $data['feedback'];
        @endphp
        <div class="field-row">
            <span class="field-label">Pertanyaan:</span>
            <span class="field-value">{{ $feedback['pertanyaan'] ?? '-' }}</span>
        </div>
        <div class="field-row">
            <span class="field-label">Saran:</span>
            <span class="field-value">{{ $feedback['saran'] ?? '-' }}</span>
        </div>
    @else
        <p>No data available</p>
    @endif
</div>

<div class="section">
    <div class="section-title">Renpra (Rencana Perawatan) - Opsional</div>
    @if(isset($data['renpra']))
        @php
        $renpra = $data['renpra'];
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
        <p>No data available</p>
    @endif
</div>

{{-- Include documentations if available --}}
@if(isset($documentations) && $documentations->count() > 0)
<div class="section">
    <div class="section-title">Dokumentasi</div>
    <table>
        <thead>
            <tr>
                <th>Jenis Dokumentasi</th>
                <th>Nama File</th>
            </tr>
        </thead>
        <tbody>
            @foreach($documentations as $doc)
                <tr>
                    <td>{{ ucfirst($doc->type) }}</td>
                    <td>{{ basename($doc->file_path) }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>
</div>
@endif
@endsection