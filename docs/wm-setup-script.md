# Managing Welcome Messages
### Script for managing chatbot Welcome Messages

+ [Introduction](#intro)
+ [Getting started](#getting-started)
+ [Managing Welcome Messages](#managing)
  + [Creating Welcome Message](#creating)
  + [Listing Welcome Message](#listing)
  + [Setting default Welcome Message](#setting-default)
  + [Deleting Welcome Message](#deleting)
+ [Updating default Welcome Message](#updating)  
+ [Testing default Welcome Message](#testing)

## Introduction <a id="intro" class="tall">&nbsp;</a>

As you develop your chatbot, its Welcome Message will change and evolve. Each time you iterate it, you'll need to tear down the current one and assign the new one. The purpose of this Ruby script is to help automate that process. This script is designed to take one or two command-line parameters and manage API calls that create, delete, set, and list Welcome Messages. 

This script comes along with a clone of the [SnowBotDev repository](https://github.com/jimmoffitt/SnowBotDev), in the ./scripts directory. There is also a script for [managing chatbot 'plumbing' details](https://github.com/jimmoffitt/SnowBotDev/blob/master/docs/aaa-setup-script.md).

If you are a Node.js developer, checkout these [Node-based Welcome Message scripts](https://github.com/twitterdev/twitter-webhook-boilerplate-node/tree/master/example_scripts/welcome_messages).

## Getting started <a id="getting-started" class="tall">&nbsp;</a>

The **set_welcome_messages.rb** helps manage requests to the Twitter [Direct Message API](https://developer.twitter.com/en/docs/direct-messages/beta-features). 

When you run this script you have several options. 
 
```$ruby ./scripts/setup_welcome_messages.rb -h```

```
Usage: setup_welcome_message [options]
    -w, --default WELCOME            Default Welcome Management: 'create', 'set', 'get', 'delete'
    -r, --rule RULE                  Welcome Message Rule management: 'create', 'get', 'delete'
    -i, --id ID                      Message or rule ID
    -h, --help                       Display this screen.
```

+ The script requires two standard gems:

```
require 'json'
require 'optparse'
```

+ The script also requires two other SnowBotDev project objects:


This Ruby ```ApiOauthRequest``` class manages and abstracts away the OAuth authentication details:

```
require_relative '../app/helpers/api_oauth_request'
```

This Ruby ```GenerateDirectMessageContent``` class contains the bot-specific Welcome Messages and Quick Reply content: 

```
require_relative '../app/helpers/generate_direct_message_content'
```

Since this script depends on the @SnowBotDev's DM content, content that differs from bot to bot, you'll want this script's functionality in the same language as the rest of your bot. If you are developing with Node.js, then check out this [Node-based Welcome Message script].

See the project's Gemfile for more details about what gems are needed for the Sinatra web app. 


## Managing Welcome Messages <a id="managing" class="tall">&nbsp;</a> 

* [Creating Welcome Message](#creating)
* [Listing Welcome Messages](#listing)
* [Assigning default Welcome Message](#setting)
* [Updating default Welcome Message](#updating)
* [Testing default Welcome Message](#testing)
* [Other details](#details)

### Creating Welcome Message <a id="creating" class="tall">&nbsp;</a>

One of the first steps of deploying a bot is designing your Welcome Message. 

-w "create"

This command will call the ```generate_welcome_message_default``` method of the ```GenerateDirectMessageContent``` object

```

Creating GenerateDirectMessageContent object.
Creating Welcome Message...
```

### Listing Welcome Messages <a id="listing" class="tall">&nbsp;</a>

```
Creating Welcome Message...
error code: 403 #<Net::HTTPForbidden:0x007ff29903f230>
Errors occurred.
{"code"=>151, "message"=>"There was an error sending your message: Field description is not present in all options."}
```

-w "get"

```
Creating GenerateDirectMessageContent object.
Getting welcome message list.
Message IDs: 
Message ID 913875901732941829 with message: ❄ Welcome to snowbot (ver. 0.05) ❄ 
```

### Setting default Welcome Message <a id="setting-default" class="tall">&nbsp;</a>

-w "set" -i 913875901732941829

```
Creating GenerateDirectMessageContent object.
Setting default Welcome Message to message with id 913875901732941829...

```

Remember, as noted [HERE](https://developer.twitter.com/en/docs/direct-messages/quick-replies/api-reference/options), if you set option descriptions (and you probably should, they are helpful), you need to set them for all options or an error message will be returned when attempting to set the message.

### Deleting Welcome Message <a id="deleting" class="tall">&nbsp;</a>

As you iterate the design of your Welcome Message, you will want to delete previous designs. 

-w "delete" -i 883450462757765123

```
Deleting Welcome Message with id: 883450462757765123.
Deleted message id: 883450462757765123
```

-w "get"

```
Getting welcome message list.
Message IDs: 
Message ID 890789035756503044 with message: ❄ Welcome to snowbot ❄ 
Message ID 893578135685406724 with message: ❄ Welcome to snowbot ❄ 
Message ID 893579774534209539 with message: ❄ Welcome to snowbot (ver. 0.02) ❄ 
```

Here we see some debris... The one with the versioned message is the current one, and the other two are early ones that can be deleted. Note that there are common use-cases where you need multiple welcome messages, such as a 'under maintenance' message. This is not such a use-case, so let's go ahead and delete the unwanted welcome messages.

-w "delete" -i 890789035756503044

```
Deleting Welcome Message with id: 890789035756503044.
Deleted message id: 890789035756503044
```
-w "delete" -i 893578135685406724

If you try to delete an unexisting Welcome Message ID: 

-w "get"

```
Getting welcome message list.
Message IDs: 
Message ID 893579774534209539 with message: ❄ Welcome to snowbot (ver. 0.02) ❄ 
```
## Updating default Welcome Mesasage <a id="updating" class="tall">&nbsp;</a> 

As you develop your chatbot, your default Welcome Message will likely evolve and change many times. When it's time to make an update, here are the steps that need to be taken:

+ Create new Welcome Message.
+ Delete existing Welcome Message rule.
+ Set the new Welcome Message as the new default.

Using this helper script, we can easily take those steps:

+ Create new Welcome Message:
```
setup_welcome_messages.rb -w "create"

>> Creating Welcome Message...

```

+ List messages, confirming we have two messages, old and new:

```
setup_welcome_messages.rb -w "get"

>> Getting welcome message list.
>> Message IDs: 
>> Message ID 948357678862024708 with message: ❄ Welcome to SnowBotDev (ver. 0.6) ❄ 
>> Message ID 948605959420641285 with message: ❄ Welcome to SnowBotDev (ver. 0.7) ❄ 

```

+ List current Welcome Message rule to retrieve its ID:

```
setup_welcome_messages.rb -r "get"

>> Getting welcome message rules list.
>>Rule 948358533958967296 points to 948357678862024708

```

+ Delete current Welcome Message rule, referencing the current rule ID:

```
setup_welcome_messages.rb -r "delete" -i 948358533958967296 
>> Deleting rule with id: 948358533958967296.
```

+ Set the updated Welcome Message as the new default.
```
-w "set" -i 948605959420641285
```

This method sets the new Welcome Message rule. This can be comfirmed by listing the rules:

```
setup_welcome_messages.rb -r "get"

>> Getting welcome message rules list.
>> Rule 948611569490984960 points to 948605959420641285

```

Now is a good time to delete the old Welcome Message:

```
setup_welcome_messages.rb -w "delete" -i 948357678862024708

```

Now you can confirm the new default Welcome Message by starting a new Direct Message conversation with your chatbot (deleting an existing conversation if need be).


## Test default Welcome Message <a id="testing" class="tall">&nbsp;</a> 

After creating or updating your default Welcome Message, you can confirm it renders the way you intend by starting a new Direct Message conversation with your chatbot's account. If you already have an established conversation, you will need to delete it. When a conversation is deleted, the account you were messaging with will not be listed when you go to create a new Direct Message.

To start a new conversation, click the "add conversation" (envelope icon with plus sign) and start adding the account name of the chatbot. 

## Other details <a id="details" class="tall">&nbsp;</a> 

**Bot account must accept DM from any user. If not, the following error will be thrown:**

```
Creating GenerateDirectMessageContent object.
Creating Welcome Message...
POST ERROR occurred with /1.1/direct_messages/welcome_messages/new.json, request: {"welcome_message":{"message_data":{"text":"❄ Welcome to snowbot (ver. 0.05) ❄","quick_reply":{"type":"options","options":[{"label":"❄ See snow picture 📷","description":"Come on, take a look...","metadata":"see_photo"},{"label":"❄ Weather data from anywhere","description":"Select an exact location or Twitter Place...","metadata":"weather_info"},{"label":"❄ Learn something new about snow","description":"Other than it melts around 32°F and is fun to slide on...","metadata":"learn_snow"},{"label":"❄ Get geo, weather themed playlist","description":"Carefully curated Spotify playlists...'","metadata":"snow_music"},{"label":"❄ Request snow report","description":"Select areas mainly in CO, with some in CA, MN and NZ.","metadata":"snow_report"},{"label":"❓ Learn more about this system","description":"At least a link to underlying code...","metadata":"learn_more"},{"label":"☔ Help","description":"Help with system commands","metadata":"help"},{"label":"⌂ Home","description":"Go back home","metadata":"return_home"}]}}}} 
Error code: 400 #<Net::HTTPBadRequest:0x007fa752544b78>
Error Message: {"errors":[{"code":214,"message":"owner must allow dms from anyone"}]}
```

**You'll receive an error if you include a Quick Reply/Welcome Message with a web link in the description:**

For example, the following Quick Reply option has a description with the ```SnoCountry.com``` web address:

```
  option = {}
	option['label'] = "#{BOT_CHAR} Request snow report"
	option['description'] = 'SnoCountry.com reports for select areas.'
	option['metadata'] = 'snow_report'
	options << option
```

Attempting to create this Welcome Message/Quick Reply results in the following error:

```
Error code: 403 #<Net::HTTPForbidden:0x007f9527518998>
Error Message: {"errors":[{"code":151,"message":"There was an error sending your message: Invalid QuickReply field description containing url(s)."}]}
```


