<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphOne;

class SapForm extends Model
{
    protected $fillable = [
        'user_id', 'patient_id', 'status',
        'topik', 'sub_topik', 'sasaran', 'tanggal_pelaksanaan', 'waktu_pelaksanaan',
        'tempat', 'durasi', 'tujuan_umum', 'tujuan_khusus', 'materi_penyuluhan',
        'metode', 'media', 'kegiatan', 'evaluasi_struktur', 'evaluasi_proses',
        'evaluasi_hasil', 'materi_file_path', 'dokumentasi_foto_path'
    ];

    protected $casts = [
        'tanggal_pelaksanaan' => 'date',
        'metode' => 'array',
        'media' => 'array',
        'kegiatan' => 'array',
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
