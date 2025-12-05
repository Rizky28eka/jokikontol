<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphOne;

class ResumePoliklinikForm extends Model
{
    protected $fillable = [
        'user_id', 'patient_id', 'status',
        'nama_pasien', 'no_rm', 'tanggal_kunjungan', 'poliklinik',
        'keluhan_utama', 'riwayat_penyakit_sekarang', 'riwayat_penyakit_dahulu',
        'riwayat_pengobatan', 'riwayat_alergi',
        'kesadaran', 'tekanan_darah', 'nadi', 'suhu', 'pernapasan', 'berat_badan', 'tinggi_badan',
        'penampilan', 'perilaku', 'mood_afek', 'pikiran',
        'diagnosis', 'terapi_farmakologi', 'terapi_non_farmakologi', 'edukasi',
        'tanggal_kontrol_berikutnya', 'rencana_tindak_lanjut'
    ];

    protected $casts = [
        'tanggal_kunjungan' => 'date',
        'tanggal_kontrol_berikutnya' => 'date',
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
