<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Documentation extends Model
{
    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'form_id',
        'file_path',
        'type',
    ];

    /**
     * Get the form that owns the documentation.
     */
    public function form(): BelongsTo
    {
        return $this->belongsTo(Form::class);
    }
}
