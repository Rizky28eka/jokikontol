<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('resume_kegawatdaruratan_forms', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('patient_id');
            $table->enum('status', ['draft', 'submitted', 'revised', 'approved'])->default('draft');
            
            // Identitas
            $table->string('nama_pasien')->nullable();
            $table->string('no_rm')->nullable();
            $table->date('tanggal_masuk')->nullable();
            $table->time('jam_masuk')->nullable();
            $table->date('tanggal_keluar')->nullable();
            $table->time('jam_keluar')->nullable();
            
            // Anamnesis
            $table->text('keluhan_utama')->nullable();
            $table->text('riwayat_penyakit_sekarang')->nullable();
            $table->text('riwayat_penyakit_dahulu')->nullable();
            $table->text('riwayat_pengobatan')->nullable();
            
            // Pemeriksaan Fisik
            $table->string('kesadaran')->nullable();
            $table->string('gcs')->nullable();
            $table->string('tekanan_darah')->nullable();
            $table->string('nadi')->nullable();
            $table->string('suhu')->nullable();
            $table->string('pernapasan')->nullable();
            $table->string('spo2')->nullable();
            
            // Status Mental
            $table->text('penampilan')->nullable();
            $table->text('perilaku')->nullable();
            $table->text('pembicaraan')->nullable();
            $table->text('mood_afek')->nullable();
            $table->text('pikiran')->nullable();
            $table->text('persepsi')->nullable();
            $table->text('kognitif')->nullable();
            
            // Diagnosis & Tindakan
            $table->text('diagnosis_kerja')->nullable();
            $table->text('tindakan_yang_dilakukan')->nullable();
            $table->text('terapi_obat')->nullable();
            
            // Kondisi Keluar
            $table->enum('kondisi_keluar', ['Membaik', 'Belum Membaik', 'Meninggal', 'Pulang Paksa'])->nullable();
            $table->text('anjuran')->nullable();
            
            $table->timestamps();
            
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('patient_id')->references('id')->on('patients')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('resume_kegawatdaruratan_forms');
    }
};
