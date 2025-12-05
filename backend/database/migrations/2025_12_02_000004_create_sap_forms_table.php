<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sap_forms', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('patient_id');
            $table->enum('status', ['draft', 'submitted', 'revised', 'approved'])->default('draft');
            
            // Identitas SAP
            $table->string('topik')->nullable();
            $table->string('sub_topik')->nullable();
            $table->string('sasaran')->nullable();
            $table->date('tanggal_pelaksanaan')->nullable();
            $table->time('waktu_pelaksanaan')->nullable();
            $table->string('tempat')->nullable();
            $table->integer('durasi')->nullable(); // dalam menit
            
            // Tujuan
            $table->text('tujuan_umum')->nullable();
            $table->text('tujuan_khusus')->nullable();
            
            // Materi
            $table->text('materi_penyuluhan')->nullable();
            
            // Metode & Media
            $table->json('metode')->nullable(); // ['Ceramah', 'Diskusi', 'Demonstrasi', dll]
            $table->json('media')->nullable(); // ['Leaflet', 'PowerPoint', 'Video', dll]
            
            // Kegiatan Penyuluhan
            $table->json('kegiatan')->nullable(); // [{tahap, kegiatan_penyuluh, kegiatan_peserta, waktu}]
            
            // Evaluasi
            $table->text('evaluasi_struktur')->nullable();
            $table->text('evaluasi_proses')->nullable();
            $table->text('evaluasi_hasil')->nullable();
            
            // Lampiran
            $table->string('materi_file_path')->nullable();
            $table->string('dokumentasi_foto_path')->nullable();
            
            $table->timestamps();
            
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('patient_id')->references('id')->on('patients')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sap_forms');
    }
};
