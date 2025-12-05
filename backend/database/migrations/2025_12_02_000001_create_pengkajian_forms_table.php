<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pengkajian_forms', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('patient_id');
            $table->enum('status', ['draft', 'submitted', 'revised', 'approved'])->default('draft');
            
            // Identitas Pasien
            $table->string('nama_lengkap')->nullable();
            $table->string('tempat_lahir')->nullable();
            $table->date('tanggal_lahir')->nullable();
            $table->integer('usia')->nullable();
            $table->enum('jenis_kelamin', ['Laki-laki', 'Perempuan'])->nullable();
            $table->string('agama')->nullable();
            $table->string('suku')->nullable();
            $table->string('pendidikan')->nullable();
            $table->string('pekerjaan')->nullable();
            $table->text('alamat')->nullable();
            $table->string('no_rm')->nullable();
            $table->date('tanggal_masuk')->nullable();
            $table->string('diagnosa_medis')->nullable();
            
            // Keluhan Utama
            $table->text('keluhan_utama')->nullable();
            
            // Riwayat Kesehatan
            $table->text('riwayat_penyakit_sekarang')->nullable();
            $table->text('riwayat_penyakit_dahulu')->nullable();
            $table->text('riwayat_penyakit_keluarga')->nullable();
            $table->text('riwayat_pengobatan')->nullable();
            
            // Pemeriksaan Fisik
            $table->string('tekanan_darah')->nullable();
            $table->string('nadi')->nullable();
            $table->string('suhu')->nullable();
            $table->string('pernapasan')->nullable();
            $table->string('tinggi_badan')->nullable();
            $table->string('berat_badan')->nullable();
            
            // Psikososial
            $table->text('konsep_diri')->nullable();
            $table->text('hubungan_sosial')->nullable();
            $table->text('spiritual')->nullable();
            
            // Genogram
            $table->json('genogram_structure')->nullable();
            $table->text('genogram_notes')->nullable();
            
            // Status Mental
            $table->text('penampilan')->nullable();
            $table->text('pembicaraan')->nullable();
            $table->text('aktivitas_motorik')->nullable();
            $table->text('alam_perasaan')->nullable();
            $table->text('afek')->nullable();
            $table->text('interaksi')->nullable();
            $table->text('persepsi')->nullable();
            $table->text('proses_pikir')->nullable();
            $table->text('isi_pikir')->nullable();
            $table->text('tingkat_kesadaran')->nullable();
            $table->text('memori')->nullable();
            $table->text('tingkat_konsentrasi')->nullable();
            $table->text('orientasi')->nullable();
            $table->text('daya_tilik_diri')->nullable();
            
            // Kebutuhan Persiapan Pulang
            $table->boolean('makan_mandiri')->default(false);
            $table->boolean('bab_bak_mandiri')->default(false);
            $table->boolean('mandi_mandiri')->default(false);
            $table->boolean('berpakaian_mandiri')->default(false);
            $table->boolean('istirahat_tidur_cukup')->default(false);
            $table->text('kebutuhan_persiapan_pulang_lainnya')->nullable();
            
            // Mekanisme Koping
            $table->text('mekanisme_koping')->nullable();
            
            // Masalah Psikososial
            $table->json('masalah_psikososial')->nullable();
            
            // Aspek Medik
            $table->text('diagnosa_medis_lengkap')->nullable();
            $table->text('terapi_medis')->nullable();
            
            $table->timestamps();
            
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('patient_id')->references('id')->on('patients')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pengkajian_forms');
    }
};
