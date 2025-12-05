<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('catatan_tambahan_forms', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('patient_id');
            $table->enum('status', ['draft', 'submitted', 'revised', 'approved'])->default('draft');
            
            $table->date('tanggal_catatan')->nullable();
            $table->time('waktu_catatan')->nullable();
            $table->string('kategori')->nullable(); // Observasi, Tindakan, Evaluasi, dll
            $table->text('catatan')->nullable();
            $table->text('tindak_lanjut')->nullable();
            
            $table->timestamps();
            
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('patient_id')->references('id')->on('patients')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('catatan_tambahan_forms');
    }
};
