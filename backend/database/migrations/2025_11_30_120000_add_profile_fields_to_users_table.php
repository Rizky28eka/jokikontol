<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('username')->nullable()->unique()->after('name');
            $table->string('phone_number')->nullable()->unique()->after('email');
            $table->string('profile_photo')->nullable()->after('phone_number');
            $table->timestamp('username_changed_at')->nullable()->after('profile_photo');
            $table->timestamp('phone_changed_at')->nullable()->after('username_changed_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'username',
                'phone_number',
                'profile_photo',
                'username_changed_at',
                'phone_changed_at'
            ]);
        });
    }
};
