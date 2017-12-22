
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

To build out the client-side of a Twitter chatbot, you need to deploy a web app with an endpoint to handle incoming webhook events. For this project, the ```https://snowbotdev.herokuapp.com/snowbot``` endpoint was registered with Twitter using the Account Activity API: 

+ Twitter will POST all Account Activity webhook events to: https://snowbotdev.herokuapp.com/snowbot. The event will come in the form of a JSON object. 
+ Twitter will also make a GET request to the https://snowbotdev.herokuapp.com/snowbot endpoint when sends a Challenge Response Check (CRC) event.

These two routes are required, and you also have the option to a web app home page as well. When building a Sinatra app, this means building a *controller* that is mapped to the https://snowbotdev.herokuapp.com/snowbot endpoint with these methods:

```
require 'sinatra'

class SnowBotApp < Sinatra::Base

 def initialize
   super()
 end

 //Add routes, methods, etc.
 
 get '/' do # Provide chatbot home page.
 end
   
 post '/snowbot' do # Receive webhook events. Data body consists of a JSON object describing event.
 end
   
 get '/snowbot' do # Respond to CRC event.
 end

end

```

### Receive webhook events <a id="receiving-events" class="tall">&nbsp;</a> 

For the Snow Bot, the https://snowbotdev.herokuapp.com/snowbot URL was registered as where Twitter should send webhook events. When Twitter sends webhook events, it makes a POST request to that endpoint and sends the event encoded as JSON. The controller ```post /snowbot``` method passes that JSON content to an *event manager*.

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

When Twitter sends a CRC event, it makes a GET request to the registered endpoint along with a ```crc_token``` request parameter. The controller ```get /snowbot``` method takes that token, encodes that token with the client-side *consumer secret*, and responds with that result to Twitter. 

```
  get '/snowbot' do
    crc_token = params['crc_token']
    response = {}
    response['response_token'] = "sha256=#{generate_crc_response(settings.dm_api_consumer_secret, crc_token)}"
    body response.to_json
    status 200
  end
```
The Ruby code for generating the CRC response hash looks like this:

```
  def generate_crc_response(consumer_secret, crc_token)
    hash = OpenSSL::HMAC.digest('sha256', consumer_secret, crc_token)
    return Base64.encode64(hash).strip!
  end
```

To see the Sinatra controller that runs the Snow Bot, [checkout SnowBotDev/app/controllers/snow_bot_dev_app.rb](https://github.com/jimmoffitt/SnowBotDev/blob/master/app/controllers/snow_bot_dev_app.rb).

## Create a default Welcome Message

One of the first steps when deploying a chatbot is using the Direct Message API to set a default Welcome Message. To get started, be sure to read our [documentation on setting the default Welcome Message](https://developer.twitter.com/en/docs/direct-messages/welcome-messages/guides/setting-default-welcome-message). As described there, the first step is creating a Welcome Message and retrieving its Message ID. The second step is creating a Welcome Message Rule using that Message ID. This [Welcome Message script](https://github.com/jimmoffitt/SnowBotDev/blob/master/scripts/setup_welcome_messages.rb) can help you automate those two steps.

That script references the ```SnowBotDev/app/helpers/generate_direct_message_content.rb``` Snow Bot class, which a few methods for generating the Welcome Message JSON that is sent as a POST request to the direct_messages/welcome_messages/new endpoint:

The ```build_custom_options``` method builds an ```options``` array with label/description/metadata attributes for each custom chatbot option.
 
 ```
 def build_custom_options

		options = []

		option = {}
		option['label'] = "#{BOT_CHAR} See snow picture 📷"
		option['description'] = 'Come on, take a look...'
		option['metadata'] = 'see_photo'
		options << option

		option = {}
		option['label'] = "#{BOT_CHAR} Request snow report"
		option['description'] = 'SnoCountry.com reports for select areas.'
		option['metadata'] = 'snow_report'
		options << option
		
		option = {}
		option['label'] = "#{BOT_CHAR} Weather data from anywhere"
		option['description'] = 'Select an exact location or Twitter Place...'
		option['metadata'] = 'weather_info'
		options << option
		
		option = {}
		option['label'] = "#{BOT_CHAR} Learn something new about snow"
		option['description'] = 'Other than it melts around 32°F and is fun to slide on...'
		option['metadata'] = 'learn_snow'
		options << option

	  option = {}
		option['label'] = "#{BOT_CHAR} Get geo, weather themed playlist"
		option['description'] = "Carefully curated Spotify playlists...'"
		option['metadata'] = 'snow_music'
		options << option

		options

	end
```
The ```build_default_options``` method builds an ```options``` array with label/description/metadata attributes for each a set of default options that are added to the end of the custom options. The idea here is that regardless of the custom options a chatbot may have, there will always be a set of default options tacked on. 

```
def build_default_options

		options = []

		option = {}
		option['label'] = '❓ Learn more about this system'
		option['description'] = 'At least a link to underlying code...'
		option['metadata'] = 'learn_more'
		options << option

		option = {}
		option['label'] = '☔ Help'
		option['description'] = 'Help with system commands'
		option['metadata'] = 'help'
		options << option

		option = {}
		option['label'] = '⌂ Home'
		option['description'] = 'Go back home'
		option['metadata'] = "return_home"
		options << option

		options

	end
```

The Welcome Message script makes a call the ```generate_welcome_option``` methods, which generates the two sets of options and assembles the resulting Quick Reply JSON.

```
def generate_welcome_options
		quick_reply = {}
		quick_reply['type'] = 'options'
		quick_reply['options'] = []

		custom_options = []
		custom_options = build_custom_options
		custom_options.each do |option|
			quick_reply['options'] << option
		end

		default_options = []
		default_options = build_default_options
		default_options.each do |option|
			quick_reply['options'] << option
		end

		quick_reply
end
```

## Managing events <a id="managing" class="tall">&nbsp;</a> 

As seen previously, the Snow Bot app controller has a ```post '/snowbot'``` route that passes the incoming webhook event JSON to a ```EventManager``` helper class and its ```handle_event``` method.

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
### Handing webhook events <a id="managing-events" class="tall">&nbsp;</a> 

The ```EventManager``` class is implemented in ```SnowBotDev/app/helpers/event_manager.rb```. The ```handle_event``` method examines the incoming (Direct Message) event and determines whether it is a Quick Reply response or a bot command.

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

If the event manager is handling a Quick Reply response, the ```handle_quick_reply``` method parses both the user ID of who is responding, and the ```metadata``` associated with the Quick Reply the user is responding to. The code below illustrates how a user request for seeing a help menu is handled. 

When creating Quick Replies, the 'metadata' attribute assigned to it comes back with the Quick Reply response. This 'metadata' attribute enables you to know what Quick Reply is being responded to and react accordingly.

```
	def handle_quick_reply(dm_event)

		response_metadata = dm_event['message_create']['message_data']['quick_reply_response']['metadata']
		user_id = dm_event['message_create']['sender_id']

    # Handle all types of response_metadata here. 
		if response_metadata == 'help'
			@DMSender.send_system_help(user_id)
		end	

	end
  
```
  
### Handling bot commands <a id="managing-commands" class="tall">&nbsp;</a> 
 
If the incoming Direct Message is not a Quick Reply response, the message text (and user ID) is parsed to see of the Direct Message comtains a support bot command. In the code below, we are looking for supported commands that trigger the response of sending the bot's Welcome Message. 

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


```
def build_default_options

	options = []

	option = {}
	option['label'] = '❓ Learn more about this system'
	option['description'] = 'At least a link to underlying code...'
	option['metadata'] = 'learn_more'
	options << option

	option = {}
	option['label'] = '☔ Help'
	option['description'] = 'Help with system commands'
	option['metadata'] = 'help'
	options << option

	option = {}
	option['label'] = '⌂ Home'
	option['description'] = 'Go back home'
	option['metadata'] = "return_home"
	options << option	

	options

end
```

### Adding attachments to Direct Messages <a id="attachments" class="tall">&nbsp;</a> 
```SnowBotDev/app/helpers/twitter_api.rb```

### Serving option lists <a id="'lists" class="tall">&nbsp;</a> 

### Integrating third-party APIs <a id="other-apis" class="tall">&nbsp;</a> 
```SnowBotDev/app/helpers/third_party_request.rb```



## Other tips <a id="tips" class="tall">&nbsp;</a> 

### Deploying chatbot

### Call to action Tweets

Adding a CTA Tweet: https://twitter.com/messages/compose?recipient_id=906948460078698496

### Asking users for location

