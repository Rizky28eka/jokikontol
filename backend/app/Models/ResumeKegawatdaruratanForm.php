<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphOne;

class ResumeKegawatdaruratanForm extends Model
{
    protected $fillable = [
        'user_id', 'patient_id', 'status',
        'nama_pasien', 'no_rm', 'tanggal_masuk', 'jam_masuk', 'tanggal_keluar', 'jam_keluar',
        'keluhan_utama', 'riwayat_penyakit_sekarang', 'riwayat_penyakit_dahulu', 'riwayat_pengobatan',
        'kesadaran', 'gcs', 'tekanan_darah', 'nadi', 'suhu', 'pernapasan', 'spo2',
        'penampilan', 'perilaku', 'pembicaraan', 'mood_afek', 'pikiran', 'persepsi', 'kognitif',
        'diagnosis_kerja', 'tindakan_yang_dilakukan', 'terapi_obat', 'kondisi_keluar', 'anjuran'
    ];

    protected $casts = [
        'tanggal_masuk' => 'date',
        'tanggal_keluar' => 'date',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function patient(): BelongsTo
    {
        return $this->belongsTo(Patient::class);
    }

    public function form(): MorphOne
    {
        return $this->morphOne(Form::class, 'formable');
    }
}
