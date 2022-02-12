<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class DeviceController extends Controller
{
    /**
     * Store device Token
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function storeDeviceToken(Request $request)
    {
        try {
            DB::beginTransaction();
            $user = User::query()->where('email', env('USER_MAIL'))->firstOrFail();

            $user->update([
                'device_token' => $request->get('token'),
            ]);

            DB::commit();
            return response()->json([
                'data' => ['status' => 'SUCCESS',],
                'message' => 'Device Token Updated Successfully',
            ]);
        } catch (\Throwable $exception) {
            DB::rollBack();
            Log::error('Error while updating Device token', [
                'message' => $exception->getMessage(),
                'location' => __METHOD__,
                'request' => $request->all(),
                'trace' => $exception->getTraceAsString(),
            ]);
            return response()->json([
                'data' => ['status' => 'FAILED',],
                'message' => $exception->getMessage(),
            ], 500);
        }
    }
}
