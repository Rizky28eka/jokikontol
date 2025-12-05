<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphOne;

class PengkajianForm extends Model
{
    protected $fillable = [
        'user_id', 'patient_id', 'status',
        'nama_lengkap', 'tempat_lahir', 'tanggal_lahir', 'usia', 'jenis_kelamin',
        'agama', 'suku', 'pendidikan', 'pekerjaan', 'alamat', 'no_rm',
        'tanggal_masuk', 'diagnosa_medis', 'keluhan_utama',
        'riwayat_penyakit_sekarang', 'riwayat_penyakit_dahulu', 'riwayat_penyakit_keluarga',
        'riwayat_pengobatan', 'tekanan_darah', 'nadi', 'suhu', 'pernapasan',
        'tinggi_badan', 'berat_badan', 'konsep_diri', 'hubungan_sosial', 'spiritual',
        'genogram_structure', 'genogram_notes', 'penampilan', 'pembicaraan',
        'aktivitas_motorik', 'alam_perasaan', 'afek', 'interaksi', 'persepsi',
        'proses_pikir', 'isi_pikir', 'tingkat_kesadaran', 'memori', 'tingkat_konsentrasi',
        'orientasi', 'daya_tilik_diri', 'makan_mandiri', 'bab_bak_mandiri',
        'mandi_mandiri', 'berpakaian_mandiri', 'istirahat_tidur_cukup',
        'kebutuhan_persiapan_pulang_lainnya', 'mekanisme_koping', 'masalah_psikososial',
        'diagnosa_medis_lengkap', 'terapi_medis'
    ];

    protected $casts = [
        'tanggal_lahir' => 'date',
        'tanggal_masuk' => 'date',
        'genogram_structure' => 'array',
        'masalah_psikososial' => 'array',
        'makan_mandiri' => 'boolean',
        'bab_bak_mandiri' => 'boolean',
        'mandi_mandiri' => 'boolean',
        'berpakaian_mandiri' => 'boolean',
        'istirahat_tidur_cukup' => 'boolean',
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
