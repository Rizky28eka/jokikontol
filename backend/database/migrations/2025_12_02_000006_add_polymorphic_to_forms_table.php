<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('forms', function (Blueprint $table) {
            // Add polymorphic columns to reference specific form tables
            $table->string('formable_type')->nullable()->after('type');
            $table->unsignedBigInteger('formable_id')->nullable()->after('formable_type');
            
            // Keep existing columns for backward compatibility
            // data column will be deprecated but kept for migration period
        });
    }

    public function down(): void
    {
        Schema::table('forms', function (Blueprint $table) {
            $table->dropColumn(['formable_type', 'formable_id']);
        });
    }
};
