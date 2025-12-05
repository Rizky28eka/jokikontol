<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\Relations\MorphTo;

class Form extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'type',
        'user_id',
        'patient_id',
        'status',
        'data',
        'formable_type',
        'formable_id',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'data' => 'array',
    ];

    /**
     * Get the user that owns the form.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the patient that the form belongs to.
     */
    public function patient(): BelongsTo
    {
        return $this->belongsTo(Patient::class);
    }

    /**
     * Get the genogram associated with the form.
     */
    public function genogram(): HasOne
    {
        return $this->hasOne(Genogram::class);
    }

    /**
     * Get the documentations associated with the form.
     */
    public function documentations()
    {
        return $this->hasMany(Documentation::class);
    }

    /**
     * Get the revisions associated with the form.
     */
    public function revisions()
    {
        return $this->hasMany(Revision::class);
    }

    /**
     * Get the formable model (polymorphic).
     */
    public function formable(): MorphTo
    {
        return $this->morphTo();
    }
}