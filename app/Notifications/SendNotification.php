<?php

namespace App\Notifications;

use App\Packages\FcmMessage;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Notification;

class SendNotification extends Notification
{
    use Queueable;

    /**
     * Get the notification's delivery channels.
     *
     * @param $notifiable
     * @return array
     */
    public function via($notifiable)
    {
        return ['fcm'];
    }

    /**
     * @param $notifiable
     * @return FcmMessage
     */
    public function toFcm($notifiable)
    {
        return (new FcmMessage())
            ->to($notifiable->device_token)
            ->content([
                'title' => 'Test Notification',
                'body' => 'Test Notification Body',
                'icon' => 'https://docs.dockr.in/logo/half.png', // Optional
                'image' => 'https://docs.dockr.in/logo/half.png', // Optional
            ])
            ->data([
                'param1' => 'baz' // Optional
            ])
            ->priority(FcmMessage::PRIORITY_HIGH);
    }
}
