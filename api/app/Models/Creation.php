<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Carbon;

/**
 *
 * @property int $id
 * @property string $title
 * @property string $json_data
 * @property-read Carbon $created_at
 * @property-read Carbon $updated_at
 */
class Creation extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'json_data',
    ];
}
