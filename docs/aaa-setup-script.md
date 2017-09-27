# Script for managing Account Activity API configuration

## Setting up webhooks

The setup_webooks.rb script helps automate Account Activity configuration management. https://dev.twitter.com/webhooks/managing

```
Usage: setup_webhooks [options]
    -c, --config CONFIG              Configuration file (including path) that provides account OAuth details. 
    -t, --task TASK                  Securing Webhooks Task to perform: trigger CRC ('crc'), set config ('set'), list configs ('list'), delete config ('delete'), subscribe app ('subscribe'), unsubscribe app ('unsubscribe'),get subscription ('subscription').
    -u, --url URL                    Webhooks 'consumer' URL, e.g. https://mydomain.com/webhooks/twitter.
    -i, --id ID                      Webhook ID
    -h, --help                       Display this screen.  
```


Here are some example commands:


  + setup_webhooks.rb -t "set" -u "https://snowbotdev.herokuapp.com/snowbot"
  
```
Setting a webhook configuration...
Created webhook instance with webhook_id: 890716673514258432 | pointing to https://snowbotdev.herokuapp.com/snowbot
```
  
If your web app is not running, or your CRC code is not quite ready, you will receive the following response:  
  
```
  Setting a webhook configuration...
error code: 400 #<Net::HTTPBadRequest:0x007ffe0f710f10>
{"code"=>214, "message"=>"Webhook URL does not meet the requirements. Please consult: https://dev.twitter.com/webhooks/securing"}
```  
  + setup_webhooks.rb -t "list"

```
Retrieving webhook configurations...
Webhook ID 890716673514258432 --> https://snowbotdev.herokuapp.com/snowbot
```

  + setup_webhooks.rb -t "delete" -i 883437804897931264 
  
```
Attempting to delete configuration for webhook id: 883437804897931264.
Webhook configuration for 883437804897931264 was successfully deleted.
```


### Adding Subscriptions to a Webhook ID

  + setup_webhooks.rb -t "subscribe" -i webhook_id
  
```
Setting subscription for 'host' account for webhook id: 890716673514258432
Webhook subscription for 890716673514258432 was successfully added.
```

  + setup_webhooks.rb -t "unsubscribe" -i webhook_id
  
```
Attempting to delete subscription for webhook: 890716673514258432.
Webhook subscription for 890716673514258432 was successfully deleted.
```

  + setup_webhooks.rb -t "subscription" -i webhook_id
  
```
Retrieving webhook subscriptions...
Webhook subscription exists for 890716673514258432.
```


### Triggering CRC check 

  + setup_webhooks.rb -t "crc"

```
Retrieving webhook configurations...
204
CRC request successful and webhook status set to valid.
```

If you receive a response saying the 'Webhook URL does not meet the requirements', make sure your web app is up and running. If you are using a cloud platform, make sure your app is not hibernating. 

```
Retrieving webhook configurations...
Too Many Requests  - Rate limited...
error: #<Net::HTTPTooManyRequests:0x007fc4239c1190>
{"errors":[{"code":88,"message":"Rate limit exceeded."}]}
Webhook URL does not meet the requirements. Please consult: https://dev.twitter.com/webhook/security
```

If you receive this message you'll need to wait to retry. The default rate limit is one request every 15 minutes. 

