<?php

use App\Http\Controllers\CreationApiController;
use App\Models\Creation;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::get('/', function (Request $request) {
    return response()->json(['status' => 'ok']);
});

Route::get('/creations/{page?}', [CreationApiController::class, 'list']);
Route::post('/creations/share', [CreationApiController::class, 'create']);
