# Managing Welcome Message script
### Script for managing chatbot Welcome Messages

As you develop your bot, its Welcome Message will change and evolve. Each time you iterate it, you'll need to tear down the current one and assign the new one. The purpose of this Ruby script is to help automate that process. This script is designed to take one or two command-line parameters and manage API calls that create, delete, set, and list Welcome Messages. 

This script comes along with a clone of the [SnowBotDev repository](https://github.com/jimmoffitt/SnowBotDev), in the ./scripts directory. There is also a script for [managing chatbot Welcome Messages]().


## Getting started

The **set_welcome_messages.rb** helps manage requests to the Twitter [Direct Message API](https://developer.twitter.com/en/docs/direct-messages/beta-features). 

To run this script you have several options. 
 
```$ruby ./scripts/setup_welcome_messages.rb -h```

```
Usage: setup_welcome_message [options]
    -w, --default WELCOME            Default Welcome Management: 'create', 'set', 'get', 'delete'
    -r, --rule RULE                  Welcome Message Rule management: 'create', 'get', 'delete'
    -i, --id ID                      Message or rule ID
    -h, --help                       Display this screen.
```

+ Code requires two standard gems:

```
require 'json'
require 'optparse'
```

+ Code requires two other SnowBotDev project objects:


This Ruby ```ApiOauthRequest``` class manages and abstracts away the OAuth authentication details:

```
require_relative '../app/helpers/api_oauth_request'
```

This Ruby ```GenerateDirectMessageContent``` class contains the bot-specific Welcome Messages and Quick Reply content: 

```
require_relative '../app/helpers/generate_direct_message_content'
```

Since this script depends on the @SnowBotDev's DM content, content that differs from bot to bot, you'll want this script's functionality in the same language as the rest of your bot. If you are developing with Node.js, then check out this [Node-based Welcome Message sccript].

See the project's Gemfile for more details about what gems are needed for the Sinatra web app. 


## Managing Welcome Messages

* [Creating Welcome Message]()
* [Listing Welcome Messages]()
* [Assigning a default Welcome Message]()

### Creating Welcome Message

One of the first steps of deploying a bot is designing your Welcome Message. 

-w "create"

This command will call the ```generate_welcome_message_default``` method of the ```GenerateDirectMessageContent``` object

```

Creating GenerateDirectMessageContent object.
Creating Welcome Message...
```

### Listing Welcome Messages

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

### Setting default Welcome Message

-w "set" -i 913875901732941829

```
Creating GenerateDirectMessageContent object.
Setting default Welcome Message to message with id 913875901732941829...

```

<What's the story here? when one option did not have a description, this error is triggered:>


setup_welcome_message -w "delete" -i 883450462757765123

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
## Updating default Welcome Mesafe


## Validate setup


## Other details

### Bot account must accept DM from any user. If not, the following error will be thrown:

```
Creating GenerateDirectMessageContent object.
Creating Welcome Message...
POST ERROR occurred with /1.1/direct_messages/welcome_messages/new.json, request: {"welcome_message":{"message_data":{"text":"❄ Welcome to snowbot (ver. 0.05) ❄","quick_reply":{"type":"options","options":[{"label":"❄ See snow picture 📷","description":"Come on, take a look...","metadata":"see_photo"},{"label":"❄ Weather data from anywhere","description":"Select an exact location or Twitter Place...","metadata":"weather_info"},{"label":"❄ Learn something new about snow","description":"Other than it melts around 32°F and is fun to slide on...","metadata":"learn_snow"},{"label":"❄ Get geo, weather themed playlist","description":"Carefully curated Spotify playlists...'","metadata":"snow_music"},{"label":"❄ Request snow report","description":"Select areas mainly in CO, with some in CA, MN and NZ.","metadata":"snow_report"},{"label":"❓ Learn more about this system","description":"At least a link to underlying code...","metadata":"learn_more"},{"label":"☔ Help","description":"Help with system commands","metadata":"help"},{"label":"⌂ Home","description":"Go back home","metadata":"return_home"}]}}}} 
Error code: 400 #<Net::HTTPBadRequest:0x007fa752544b78>
Error Message: {"errors":[{"code":214,"message":"owner must allow dms from anyone"}]}
Errors occurred.
{"code"=>214, "message"=>"owner must allow dms from anyone"}
```

