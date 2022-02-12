<?php

namespace App\Packages;

use GuzzleHttp\Client;
use Illuminate\Notifications\Notification;

class FcmChannel
{
    /**
     * @const The API URL for Firebase
     */
    const API_URI = 'https://fcm.googleapis.com/fcm/send';

    /**
     * @var Client
     */
    private Client $client;

    /**
     * @var string
     */
    private string $apiKey;

    /**
     * @param Client $client
     * @param $apiKey
     */
    public function __construct(Client $client, $apiKey)
    {
        $this->client = $client;
        $this->apiKey = $apiKey;
    }

    /**
     * @param $notifiable
     * @param Notification $notification
     * @return array|void
     * @throws \GuzzleHttp\Exception\GuzzleException
     */
    public function send($notifiable, Notification $notification)
    {
        /** @var FcmMessage $message */
        $message = $notification->toFcm($notifiable);

        if (is_null($message->getTo()) && is_null($message->getCondition())) {
            if (!$to = $notifiable->routeNotificationFor('fcm', $notification)) {
                return;
            }

            $message->to($to);
        }

        $response_array = [];

        if (is_array($message->getTo())) {
            $chunks = array_chunk($message->getTo(), 1000);

            foreach ($chunks as $chunk) {
                $message->to($chunk);

                $response_array[] = $this->sendNotification($message);
            }

            return $response_array;
        }

        return [
            $this->sendNotification($message)
        ];
    }

    /**
     * @param $message
     * @return mixed
     * @throws \GuzzleHttp\Exception\GuzzleException
     */
    private function sendNotification($message)
    {
        $response = $this->client->post(self::API_URI, [
            'headers' => [
                'Authorization' => 'key=' . $this->apiKey,
                'Content-Type' => 'application/json',
            ],
            'body' => $message->formatData(),
        ]);

        return json_decode($response->getBody(), true);
    }
}
