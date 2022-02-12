<?php

use App\Http\Controllers\Api\V1\DeviceController;
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

Route::get('health-check', [\App\Http\Controllers\Api\HealthCheckController::class, 'healthCheck']);

Route::prefix('v1')->group(function () {
    Route::post('device-token', [DeviceController::class, 'storeDeviceToken']);
});
