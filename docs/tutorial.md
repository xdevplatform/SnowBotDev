
# Tutorial: Building a Twitter chatbot with Ruby and Sinatra
### *Building the snowbot*

+ [Introduction](#intro)
+ [Getting started](#getting-started)
  + [Helper scripts](#helper-scripts) 
+ [Building webhook consumer](#webhook-consumer)
  + [Standing up web app](#standing-up)
  + [Receive webhook events](#)
  + [Handle CRC events](#)
+ [Managing events](#managing)
  + [Twitter webhooks](#managing-events)
  + [Quick Replies](#managing-webhooks)
  + [Bot commands](#managing-commands)
+ [Adding bot functionality](#functionality)
  + [Basic menu navigation](#navigation)
  + [Add attachments to Direct Messages](#attachments)
  + [Serving option lists](#lists)
  + [Integrating third-party APIs](#other-apis)
+ [Other tips](#tips)


## Introduction <a id="intro" class="tall">&nbsp;</a>
The purpose of this tutorial is to help developers get started with the Twitter Account Activity (AA) and Direct Message (DM) APIs. These APIs are used to build Direct Message *bots*, automated systems that respond to incoming Direct Messages. To learn more about how bots have become common on the Twitter platfrom, see [HERE](https://marketing.twitter.com/na/en/insights/from-tvs-to-beertails-how-chatbots-help-brands-engage-consumers-on-twitter.html). 

These systems receive Account Activity webhook events from Twitter, process the received messages, and respond to the requester via the Direct Message API. 

+ By integrating the Account Activity (AA) API you are developing a consumer of webhook events sent from Twitter. 
+ By integrating the Direct Message (DM) API, you are building the private communication channel for your bot and its users. 

For this tutorial, we are going to build a *snow bot*, a Twitter-based gateway for all kinds of snow-related information. 

---------------------
 ####  *If you want to check out the bot, send a Direct Message to [@SnowBotDev](https://twitter.com/snowbotdev)...*
---------------------

This example bot has the following features:

* Serves a curated set of resources, such as media and URLs.
  * Serves snow photos. Demonstrates how to send attachments with Direct Messages. 
  * Serves URL links: 
    * Links to third-party snow research and information web sites. Demonstrates how to present links to external resources via Quick Replies. 
    * Links to Spotify playlists with snow and weather themes.
* Integrates third-party APIs:
  * Provides weather data for user-requested location. Data is retrieved using a WeatherUnderground API.
  * Provides snow resort reports for a set list of 20 ski resorts using http://www.snocountry.com/.
* Supports a simple bot navigation framework with common ```help```, ```about```, and ```back``` actions.

A fundamental component of any chatbot system is a webapp that reacts to Twitter webhooks and marshalls 'business' logic for reacting to incoming messages. The material below is organized in several sections including tips on getting started and overviews of implementing these bot features. 

While much of the narrative is language-agnostic, this material includes many code snippets written in Ruby. Since these code examples are very short and have comments, we can consider them as pseudo-code. Pseudo-code that hopefully illustrates fundamental concepts that are readily implemented in non-Ruby languages.

We'll start off with a how to get started with these APIs.

## Getting started <a id="getting-started" class="tall">&nbsp;</a>

First off, if you haven't reviewed the Direct Message and Account Activity API documentation, that's the place to start. 

+ https://developer.twitter.com/en/docs/direct-messages/api-features
+ https://developer.twitter.com/en/docs/accounts-and-users/subscribe-account-activity/overview

If you are new to building bots with these APIs, please check out our [Accounty Activity Playbook](). 

As described in detail [HERE](https://developer.twitter.com/en/docs/accounts-and-users/subscribe-account-activity/guides/getting-started-with-webhooks), there are several steps of getting started with developing Twitter chatbots: 

* Create Twitter app and generate access keys to use when authenticating Twitter Direct Message and Account Activity API requests.
* Get API access. Have your Twitter app enabled with the Account Activity API. For now, you'll need to apply for Account Activity API access [HERE](https://developer.twitter.com/en/apply-for-access).
* Develop webhook consumer app and set up webhooks
   * Determine client-side URL to receive webhook events.
   * Develop a webhook consumer. 
      * Handle CRC challenges from Twitter. 
      * Receive webhook events from Twitter.
* Design and deploy default Welcome Message.
 
### Helper scripts <a id="helper-scripts" class="tall">&nbsp;</a>

As you develop your chatbot, you'll need to set-up the Account Activity plumbing, and design and generate Direct Messages. Much of these actions can be thought of as one-time set-up tasks, but they are actions you'll likely take again as your chatbot evolves. 

* See [this script](https://github.com/jimmoffitt/SnowBotDev/blob/master/scripts/setup_webhooks.rb) to help with setting up your Accounty Activity access.
* See [this script](https://github.com/jimmoffitt/SnowBotDev/blob/master/scripts/setup_welcome_messages.rb) to help with managing your Welcome Messages. "As a AA API client, I need to a tool to update my default Welcome Message. I need to set one up to get started, and also will update it as my bot evolves and add new features." 

## Building webhook consumer <a id="webhook-consumer" class="tall">&nbsp;</a>

At the highest level, there are two main components of a Twitter chatbot: Twitter Accounty Activity API and the webhook events it sends, and the client-side web app that receives these events and responds with Direct Messages. This section will outline what that web app looks like when using the Ruby/sinatra framework.

If you haven't already, subscribe your consumer web app using the Account Activity API.
 
 
### Standing up web app <a id="standing-up" class="tall">&nbsp;</a> 
https://snowbotdev.herokuapp.com/
 
```
require 'sinatra'

class SnowBotApp < Sinatra::Base

 def initialize
   super()
 end
 
 //Add routes, methods, etc.

end

```

Deploy web app with an endpoint to handle incoming webhook events.
+ POST method that handles incoming Activity Account webhook events
+ GET method that implements CRC authentication requirements.




```
 //Add routes, methods, etc.
 get '/' do
 end
   
 post '/snowbot' do
 end
   
 get '/snowbot' do
 end
```

### Receive webhook events <a id="receiving-events" class="tall">&nbsp;</a> 

```
  # Receives DM events.
  post '/snowbot' do
    request.body.rewind
    events = request.body.read
    manager = EventManager.new
    manager.handle_event(events)
    status 200
  end
```

### Handle CRC events <a id="handling-crc" class="tall">&nbsp;</a> 



Receives challenge response check (CRC).

```
  get '/snowbot' do
    crc_token = params['crc_token']
    response = {}
    response['response_token'] = "sha256=#{generate_crc_response(settings.dm_api_consumer_secret, crc_token)}"
    body response.to_json
    status 200
  end
```


```
def generate_crc_response(consumer_secret, crc_token)
  hash = OpenSSL::HMAC.digest('sha256', consumer_secret, crc_token)
  return Base64.encode64(hash).strip!
end
```

+ Putting it all together. [HERE](https://github.com/jimmoffitt/SnowBotDev/blob/master/app/controllers/snow_bot_dev_app.rb) is the Snowbot's Sinatra controller. snow_bot_dev_app.rb

## Create a default Welcome Message

SnowBotDev/app/helpers/generate_direct_message_content.rb

## Managing events <a id="managing" class="tall">&nbsp;</a> 
SnowBotDev/app/helpers/event_manager.rb


```
  # Receives DM events.
  post '/snowbot' do
    request.body.rewind
    events = request.body.read
    manager = EventManager.new
    manager.handle_event(events)
    status 200
  end
```

EventManager class

```
#POST requests to /webhooks/twitter arrive here.
#Twitter Account Activity API send events as POST requests with DM JSON payloads.

require 'json'
require_relative 'send_direct_message'

class EventManager

```


### Handing webhook events <a id="managing-events" class="tall">&nbsp;</a> 

```
def handle_event(events)

		events = JSON.parse(events)
		if events.key? ('direct_message_events')

			dm_events = events['direct_message_events']
			dm_events.each do |dm_event|

				if dm_event['type'] == 'message_create'

					#Is this a response? Test for the 'quick_reply_response' key.
					is_response = dm_event['message_create'] && dm_event['message_create']['message_data'] && dm_event['message_create']['message_data']['quick_reply_response']

					if is_response
						handle_quick_reply dm_event
					else
						handle_command dm_event
					end
				end
			end
		end
	end
```

### Managing Quick Replies <a id="managing-qrs" class="tall">&nbsp;</a> 

```
	def handle_quick_reply(dm_event)

		response_metadata = dm_event['message_create']['message_data']['quick_reply_response']['metadata']
		user_id = dm_event['message_create']['sender_id']

		#Default options
		if response_metadata == 'help'
			@DMSender.send_system_help(user_id)
			
		#Custom options	
		elsif response_metadata == 'see_photo'
			@DMSender.send_photo(user_id)
	  
	end
  
```
  
### Handling bot commands <a id="managing-commands" class="tall">&nbsp;</a> 
 

```


	def handle_command(dm_event)

		#Since this DM is not a response to a QR, let's check for other 'action' commands

		request = dm_event['message_create']['message_data']['text']
		user_id = dm_event['message_create']['sender_id']
		

		if request.length <= COMMAND_MESSAGE_LIMIT and (request.downcase.include? 'bot' or request.downcase.include? 'home' or request.downcase.include? 'main' or request.downcase.include? 'hello' or request.downcase.include? 'back')
			@DMSender.send_welcome_message(user_id)

end

```

## Adding bot functionality <a id="functionality" class="tall">&nbsp;</a> 

### Basic menu navigation <a id="navigation" class="tall">&nbsp;</a> 

### Adding attachments to Direct Messages <a id="attachments" class="tall">&nbsp;</a> 
SnowBotDev/app/helpers/twitter_api.rb

### Serving option lists <a id="'lists" class="tall">&nbsp;</a> 

### Integrating third-party APIs <a id="other-apis" class="tall">&nbsp;</a> 
SnowBotDev/app/helpers/third_party_request.rb



## Other tips <a id="tips" class="tall">&nbsp;</a> 

### Deploying chatbot

### Call to action Tweets

Adding a CTA Tweet: https://twitter.com/messages/compose?recipient_id=906948460078698496

### Asking users for location

