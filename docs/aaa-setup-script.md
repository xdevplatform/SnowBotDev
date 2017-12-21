# Account Activity API script
### Script for managing webbook setup and subscriptions.

There are several 'plumbing' details that need attention before you can start receiving webhook events in your event consumer application. This script helps automate the fundamental plumbing of the webhook-based Account Activity (AA) API. These are summed up in our ["Security Webhooks"](https://developer.twitter.com/en/docs/accounts-and-users/subscribe-account-activity/guides/securing-webhooks) and ["Managing webhooks and subscriptions"](https://developer.twitter.com/en/docs/accounts-and-users/subscribe-account-activity/guides/managing-webhooks-and-subscriptions) documentations. 

Specifically, this script helps with the steps below. See our Accounty Activity API references ([Standard/Premium](https://developer.twitter.com/en/docs/accounts-and-users/subscribe-account-activity/api-reference/aaa-standard-all) and [Enterprise](https://developer.twitter.com/en/docs/accounts-and-users/subscribe-account-activity/api-reference/aaa-enterprise)) for the details. 

Note: this script is currently written wo work with the *enterprise* endpoints, the only difference is the URL endpoint details noted below.

+ Telling Twitter where to send webhook events. This can be a one-time action, but at some point you will likely need to update the client-side web URL for receiving webhook events. This script manages calls to the API 'set URL' method at these endpoints:
  + Standard: https://api.twitter.com/1.1/account_activity/direct_messages/{:env_name}/webhooks.json 
  + Enterprise: https://api.twitter.com/1.1/account_activity/webhooks.json 

+ Setting up Account Activity API subscriptions. This API is designed to enable receiving events from multiple Twitter accounts. This script manages calls to the API 'add account' method at these endpoints:
  + Standard: https://api.twitter.com/1.1/account_activity/webhooks/all/{:env_name}/subscriptions.json 
  + Enterprise: https://api.twitter.com/1.1/account_activity/webhooks/{:webhook_id}/subscriptions/all.json 

+ Managing CRC events from Twitter, and manually triggering those events.
In order to start working with the Account Activity API, your event consumer needs to correctly respond to CRC challenges from Twitter. In fact, you will not be able to set up your web hook consumer URL until this step is made. This script manages calls to the API 'test CRC' method at these endpoints:
  + Standard: https://api.twitter.com/1.1/account_activity/all/{:env_name}/webhooks/{:webhook_id}.json 
  + Enterprise: https://api.twitter.com/1.1/account_activity/webhooks/{:webhook_id}.json 

This script comes along with a clone of the [SnowBotDev repository](https://github.com/jimmoffitt/SnowBotDev), in the ./scripts directory.
There is also a script for [managing Direct Message Welcome messages](https://github.com/jimmoffitt/SnowBotDev/blob/master/scripts/setup_welcome_messages.rb).

## Getting started

The **setup_webooks.rb** script helps automate Account Activity account details. See [HERE](https://developer.twitter.com/en/docs/accounts-and-users/subscribe-account-activity/guides/managing-webhooks-and-subscriptions).

To run this script you have several options. 
 
 ```$ruby ./scripts/setup_webhooks.rb -h```

```
Usage: setup_webhooks [options]
    -c, --config CONFIG              Configuration file (including path) that provides account OAuth details. 
    -t, --task TASK                  Securing Webhooks Task to perform: trigger CRC ('crc'), set config ('set'), list configs ('list'),                                        delete config ('delete'), subscribe app ('subscribe'), unsubscribe app ('unsubscribe'),get                                                subscription ('subscription').
    -u, --url URL                    Webhooks 'consumer' URL, e.g. https://mydomain.com/webhooks/twitter.
    -i, --id ID                      Webhook ID
    -h, --help                       Display this screen.  
```

+ Code requires three gems:

```
require 'json'
require 'cgi'
require 'optparse'
```

+ Code requires one other SnowBotDev project objects:

This Ruby class manages and abstracts away the OAuth authentication details:

```
require_relative '../app/helpers/api_oauth_request'
```


-------------------
Here are some common uses for this script:

+ [Setting client-side URL for webhook events.](#setting-up) 
    + Where should we send the event JSON?
    + Looking up what webhook IDs are set up. 
    + Confirming what webhook 'bridges' have been set up.
    + Note: this will trigger a CRC challenge from Twitter, so be sure you are correctly handling that. 
    
+ [Triggering a CRC challenge](#crc)

+ [Adding or deleting Twitter accounts to Account Activity API](#subscriptions)

+ [Updating event consumer URL](#updating)

-------------------

## Setting up webhooks <a id="setting-up" class="tall">&nbsp;</a>

Here are some example commands:

+ setup_webhooks.rb -t **"list"**

    ```
    Retrieving webhook configurations...
    No existing configurations... 
    ```

+ setup_webhooks.rb -t **"set"** -u "https://snowbotdev.herokuapp.com/snowbot"
 
    ```
    Setting a webhook configuration...
    Created webhook instance with webhook_id: 890716673514258432 | pointing to https://snowbotdev.herokuapp.com/snowbot
    ```
 
If your web app is not running, or your CRC code is not quite ready, you will receive the following response:  
  
    ```
    Setting a webhook configuration...
    error code: 400 #<Net::HTTPBadRequest:0x007ffe0f710f10>
    {"code"=>214, "message"=>"Webhook URL does not meet the requirements. Please consult: https://developer.twitter.com/en/docs/accounts-and-users/subscribe-account-activity/guides/securing-webhooks"}
    ```  

+ setup_webhooks.rb -t "list"

    ```
    Retrieving webhook configurations...
    Webhook ID 890716673514258432 --> https://snowbotdev.herokuapp.com/snowbot
    ```

+ setup_webhooks.rb -t **"delete"** -i 883437804897931264 
  
    ```
    Attempting to delete configuration for webhook id: 883437804897931264.
    Webhook configuration for 883437804897931264 was successfully deleted.
    ```

### Triggering CRC check <a id="crc" class="tall">&nbsp;</a>

Check out our 'Securing webhooks' documentation [HERE](https://developer.twitter.com/en/docs/accounts-and-users/subscribe-account-activity/guides/securing-webhooks).

+ setup_webhooks.rb -t **"crc"**

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

### Adding Subscriptions to a Webhook ID <a id="subscriptions" class="tall">&nbsp;</a>

+ setup_webhooks.rb -t **"subscribe"** -i webhook_id
  
    ```
    Setting subscription for 'host' account for webhook id: 890716673514258432
    Webhook subscription for 890716673514258432 was successfully added.
    ```

+ setup_webhooks.rb -t **"unsubscribe"** -i webhook_id
  
    ```
    Attempting to delete subscription for webhook: 890716673514258432.
    Webhook subscription for 890716673514258432 was successfully deleted.
    ```

+ setup_webhooks.rb -t "subscription" -i webhook_id
  
    ```
    Retrieving webhook subscriptions...
    Webhook subscription exists for 890716673514258432.
    ```

### Updating Webhook URL <a id="updating-url" class="tall">&nbsp;</a>

Sometimes you need to have the Twitter AA API point to a new client-side webhook URL. When building a bot, you may have Twitter initially send webhook events to a development site, then later point to a production system. 

When this is the case, you need to first delete the current webhook maping, then create a new one. 

+  setup_webhooks.rb -t "list"
    
    ```
    Retrieving webhook configurations...
    Webhook ID 890716673514258432 --> https://snowbotdev_test.herokuapp.com/snowbot
    ```

+ setup_webhooks.rb -t "delete" -i 890716673514258432 
 
    ```
    Attempting to delete configuration for webhook id: 890716673514258432.
    Webhook configuration for 890716673514258432 was successfully deleted.
    ```

Running a 'list' task should confirm there are no longer any webhook ids set up for this Twitter app.

Now, we are ready to update to our production 

+ setup_webhooks.rb -t "set" -u "https://snowbotdev.herokuapp.com/snowbotdev"


### Error responses


+ Only set the consumer key and secret.

```
Setting a webhook configuration...
POST ERROR occurred with /1.1/account_activity/webhooks.json?url=https%3A%2F%2Fsnowbotdev.herokuapp.com%2Fsnowbotdev, request:  
Error code: 403 #<Net::HTTPForbidden:0x007f93fad1f048>
Error Message: {"errors":[{"code":261,"message":"Application cannot perform write actions. Contact Twitter Platform Operations through https://support.twitter.com/forms/platform."}]}
{"code"=>261, "message"=>"Application cannot perform write actions. Contact Twitter Platform Operations through https://support.twitter.com/forms/platform."}
```

+ Failing CRC check.

```
Setting a webhook configuration...
POST ERROR occurred with /1.1/account_activity/webhooks.json?url=https%3A%2F%2Fsnowbotdev.herokuapp.com%2Fsnowbotdev, request:  
Error code: 400 #<Net::HTTPBadRequest:0x007fe23a197840>
Error Message: {"errors":[{"code":214,"message":"Webhook URL does not meet the requirements. Please consult: https://dev.twitter.com/webhooks/securing"}]}
{"code"=>214, "message"=>"Webhook URL does not meet the requirements. Please consult: https://dev.twitter.com/webhooks/securing"}
```


```
Setting subscription for 'host' account for webhook id: 915795063925387264
POST ERROR occurred with /1.1/account_activity/webhooks/915795063925387264/subscriptions.json, request:  
Error code: 401 #<Net::HTTPUnauthorized:0x007f971b6c06d8>
Error Message: {"errors":[{"code":348,"message":"Client application is not permitted to access this user's webhook subscriptions."}]}
{"errors":[{"code":348,"message":"Client application is not permitted to access this user's webhook subscriptions."}]}
```


