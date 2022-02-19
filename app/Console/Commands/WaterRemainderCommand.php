<?php

namespace App\Console\Commands;

use App\Models\User;
use App\Notifications\SendNotification;
use Illuminate\Console\Command;

class WaterRemainderCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'remainder:water';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Send Water Drinking Remainder Notification';

    /**
     * Create a new command instance.
     *
     * @return void
     */
    public function __construct()
    {
        parent::__construct();
    }

    /**
     * Execute the console command.
     *
     * @return void
     */
    public function handle()
    {
        if (isOfficeHours()) {
            User::where('email', env('USER_MAIL'))
                ->first()
                ->notify(new SendNotification(
                    'Water Remainder',
                    'Drink a Glass of water',
                    remainderAsset('water'),
                ));
        }
    }
}
