<?php

namespace App\Notifications;

use App\Packages\FcmMessage;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Notification;

class SendNotification extends Notification implements shouldQueue
{
    use Queueable;

    /**
     * @var string
     */
    protected string $title;

    /**
     * @var string
     */
    protected string $message;

    /**
     * @var string|null
     */
    protected ?string $image;

    /**
     * @param string $title
     * @param string $body
     * @param string|null $image
     */
    public function __construct(string $title, string $body, string $image = null)
    {
        $this->title = $title;
        $this->message = $body;
        $this->image = $image;
    }

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
        $content = [
            'title' => $this->title,
            'body' => $this->message,
        ];

        if (!is_null($this->image)) {
            $content['image'] = $this->image;
        }

        return (new FcmMessage())
            ->to($notifiable->device_token)
            ->content($content)
            ->priority(FcmMessage::PRIORITY_HIGH);
    }
}
