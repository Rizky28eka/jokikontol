<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('resume_poliklinik_forms', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('patient_id');
            $table->enum('status', ['draft', 'submitted', 'revised', 'approved'])->default('draft');
            
            // Identitas
            $table->string('nama_pasien')->nullable();
            $table->string('no_rm')->nullable();
            $table->date('tanggal_kunjungan')->nullable();
            $table->string('poliklinik')->nullable();
            
            // Anamnesis
            $table->text('keluhan_utama')->nullable();
            $table->text('riwayat_penyakit_sekarang')->nullable();
            $table->text('riwayat_penyakit_dahulu')->nullable();
            $table->text('riwayat_pengobatan')->nullable();
            $table->text('riwayat_alergi')->nullable();
            
            // Pemeriksaan Fisik
            $table->string('kesadaran')->nullable();
            $table->string('tekanan_darah')->nullable();
            $table->string('nadi')->nullable();
            $table->string('suhu')->nullable();
            $table->string('pernapasan')->nullable();
            $table->string('berat_badan')->nullable();
            $table->string('tinggi_badan')->nullable();
            
            // Status Mental
            $table->text('penampilan')->nullable();
            $table->text('perilaku')->nullable();
            $table->text('mood_afek')->nullable();
            $table->text('pikiran')->nullable();
            
            // Diagnosis & Terapi
            $table->text('diagnosis')->nullable();
            $table->text('terapi_farmakologi')->nullable();
            $table->text('terapi_non_farmakologi')->nullable();
            $table->text('edukasi')->nullable();
            
            // Rencana Tindak Lanjut
            $table->date('tanggal_kontrol_berikutnya')->nullable();
            $table->text('rencana_tindak_lanjut')->nullable();
            
            $table->timestamps();
            
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('patient_id')->references('id')->on('patients')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('resume_poliklinik_forms');
    }
};
