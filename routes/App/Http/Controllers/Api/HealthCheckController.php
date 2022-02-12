<?php

namespace App\Http\Controllers\Api;

class HealthCheckController
{
    /**
     * @return \Illuminate\Http\JsonResponse
     */
    public function healthCheck()
    {
        return response()->json([], 200);
    }
}
