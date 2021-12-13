<?php

namespace Database\Seeders;

use App\Models\Creation;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     *
     * @return void
     */
    public function run()
    {
        // \App\Models\User::factory(10)->create();
        // Create random creations
        Creation::factory(10)->create();
    }
}
