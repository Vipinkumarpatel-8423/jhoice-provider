public class MyFirebaseMsgService extends FirebaseMessagingService {


    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        //handle when receive notification via data event
        if(remoteMessage.getData().size()>0){
            showNotification(remoteMessage.getData().get("title"),remoteMessage.getData().get("message"));
        }

        //handle when receive notification
        if(remoteMessage.getNotification()!=null){
            showNotification(remoteMessage.getNotification().getTitle(),remoteMessage.getNotification().getBody());
        }

    }

    private RemoteViews getCustomDesign(String title, String message){
        RemoteViews remoteViews=new RemoteViews(getApplicationContext().getPackageName(), R.layout.notification);
        remoteViews.setTextViewText(R.id.title,title);
        remoteViews.setTextViewText(R.id.message,message);
        return remoteViews;
    }

    //show notificaiton
    public void showNotification(String title,String message){


        PrefConfig prefConfig = new PrefConfig(this);

        if(prefConfig.readLoginStatus())
        {
            Intent intent=new Intent(this, dashboard.class);
            String channel_id="web_app_channel";
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            PendingIntent pendingIntent=PendingIntent.getActivity(this,0,intent,PendingIntent.FLAG_ONE_SHOT);
            Uri uri= RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
            NotificationCompat.Builder builder=new NotificationCompat.Builder(getApplicationContext(),channel_id)
                    .setSound(uri)
                    .setAutoCancel(true)
                    .setSmallIcon(R.mipmap.ic_launcher)
                    .setVibrate(new long[]{1000,1000,1000,1000,1000})
                    .setOnlyAlertOnce(true)
                    .setStyle(new NotificationCompat.BigTextStyle().bigText(title))
                    .setStyle(new NotificationCompat.BigTextStyle().bigText(message).setSummaryText("My Home"))
                    .setColor(getResources().getColor(R.color.blue))
                    .setContentIntent(pendingIntent);

            if(Build.VERSION.SDK_INT>=Build.VERSION_CODES.JELLY_BEAN){
                builder=builder.setContent(getCustomDesign(title,message));
            }
            else{
                builder=builder.setContentTitle(title)
                        .setContentText(message);
            }

            NotificationManager notificationManager= (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            if(Build.VERSION.SDK_INT>=Build.VERSION_CODES.O){
                NotificationChannel notificationChannel=new NotificationChannel(channel_id,"web_app",NotificationManager.IMPORTANCE_HIGH);
                notificationChannel.setSound(uri,null);
                notificationManager.createNotificationChannel(notificationChannel);
            }

            notificationManager.notify(0,builder.build());
        }
        else
        {
            Intent intent=new Intent(this, login.class);
            String channel_id="web_app_channel";
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            PendingIntent pendingIntent=PendingIntent.getActivity(this,0,intent,PendingIntent.FLAG_ONE_SHOT);
            Uri uri= RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
            NotificationCompat.Builder builder=new NotificationCompat.Builder(getApplicationContext(),channel_id)
                    .setSound(uri)
                    .setAutoCancel(true)
                    .setSmallIcon(R.mipmap.ic_launcher)
                    .setVibrate(new long[]{1000,1000,1000,1000,1000})
                    .setOnlyAlertOnce(true)
                    .setStyle(new NotificationCompat.BigTextStyle().bigText(title))
                    .setStyle(new NotificationCompat.BigTextStyle().bigText(message).setSummaryText("My Home"))
                    .setColor(getResources().getColor(R.color.blue))
                    .setContentIntent(pendingIntent);

            if(Build.VERSION.SDK_INT>=Build.VERSION_CODES.JELLY_BEAN){
                builder=builder.setContent(getCustomDesign(title,message));
            }
            else{
                builder=builder.setContentTitle(title)
                        .setContentText(message);
            }

            NotificationManager notificationManager= (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            if(Build.VERSION.SDK_INT>=Build.VERSION_CODES.O){
                NotificationChannel notificationChannel=new NotificationChannel(channel_id,"web_app",NotificationManager.IMPORTANCE_HIGH);
                notificationChannel.setSound(uri,null);
                notificationManager.createNotificationChannel(notificationChannel);
            }

            notificationManager.notify(0,builder.build());
        }


    }


}