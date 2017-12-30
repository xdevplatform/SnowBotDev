
# Tutorial: Building a Twitter chatbot with Ruby and Sinatra
### *Building the SnowBot*

+ [Introduction](#intro)
+ [Getting started](#getting-started)
  + [Helper scripts](#helper-scripts) 
+ [Building webhook consumer](#webhook-consumer)
  + [Standing up web app](#standing-up)
  + [Deploying web app](#deploying)
  + [Receiving webhook events](#receiving-events)
  + [Handling CRC events](#handling-crc)
+ [Managing events](#managing)
  + [Twitter webhooks](#managing-webhooks)
  + [Quick Replies](#managing-qrs)
  + [Bot commands](#managing-commands)
+ [Adding bot functionality](#functionality)
  + [Basic menu navigation](#navigation)
  + [Serving option lists](#lists)
  + [Adding attachments to Direct Messages](#attachments)
  + [Integrating third-party APIs](#other-apis)
+ [Other tips](#tips)


## Introduction <a id="intro" class="tall">&nbsp;</a>
The purpose of this tutorial is to help developers get started with the Twitter Account Activity (AA) and Direct Message (DM) APIs. These APIs are used to build Direct Message *bots*, automated systems that respond to incoming Direct Messages. To learn more about how bots have become common on the Twitter platfrom, see [HERE](https://marketing.twitter.com/na/en/insights/from-tvs-to-beertails-how-chatbots-help-brands-engage-consumers-on-twitter.html). 

These systems receive Account Activity webhook events from Twitter, process the received messages, and respond to the requester via the Direct Message API. 

+ By integrating the Account Activity (AA) API you are developing a consumer of webhook events sent from Twitter. 
+ By integrating the Direct Message (DM) API, you are building the private communication channel for your bot and its users. 

For this tutorial, we are going to build a *SnowBot*, a Twitter-based gateway for all kinds of snow-related information. 

---------------------
 ####  *If you want to check out the bot, send a Direct Message to [@SnowBotDev](https://twitter.com/messages/compose?recipient_id=906948460078698496)...*
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

### Deploying web app <a id="deploying" class="tall">&nbsp;</a> 

While this example chatbot was developed, it was deployed in two places: a cloud-based server and a local laptop server environment. 

The cloud-based host was the easiest server to stand up, and there are many services that provide the remote server. For this tutorial, the SnowBot was deployed on Heroku. The Heroku web app was synched with the Snowbotdev github repository, and deploying code updates is painless. Authentication details and app options are set in the web app's Settings. 

The local laptop environment was where the first deployment occurred and it had more complicated *network* details to work out. The complication was enabling the Twitter webhook events to post events to a laptop's private server. This hurdle was cleared by using a port forwarding ('tunneling') service that provides a public URL associated with your private server. 

For this project, ngrok was used for initial API testing and development. The free version serves up a new URL everytime, which is OK when making initial API requests, but becomes a pain when you move on to chatbot design. If you are willing to pay a small fee, then you can specify a static custom URL. The free Pagekite service was also tried. With Pagekite, the CRC always failed due to latency, which may have been user error.  


### Receiving webhook events <a id="receiving-events" class="tall">&nbsp;</a> 

For the SnowBot, the https://snowbotdev.herokuapp.com/snowbot URL was registered as where Twitter should send webhook events. When Twitter sends webhook events, it makes a POST request to that endpoint and sends the event encoded as JSON. The controller ```post /snowbot``` method passes that JSON content to an *event manager*.

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

### Handling CRC events <a id="handling-crc" class="tall">&nbsp;</a> 

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
![](https://github.com/jimmoffitt/SnowBotDev/blob/master/docs/screenshots/welcome_message.jpg)

## Managing events <a id="managing" class="tall">&nbsp;</a> 

Chatbots are driven by real-time communication events. The SnowBot receives Twitter Account Activity webhook events and responds with Direct Messages.     

The SnowBot (sinatra) controller has a ```post '/snowbot'``` route that passes the incoming webhook event JSON to a ```EventManager``` helper class and its ```handle_event``` method. Here's how that route is implemented:

```
  # Receives Account Activity API webhook events.
  post '/snowbot' do
    request.body.rewind
    events = request.body.read
    manager = EventManager.new
    manager.handle_event(events)
    status 200
  end
```

The entire app controller code is at [SnowBotDev/app/controllers/snow_bot_dev_app.rb](https://github.com/jimmoffitt/SnowBotDev/blob/master/app/controllers/snow_bot_dev_app.rb).

We'll split the event management discussion into three parts:

+ Handling webhook events - Processing incoming Accunt Activity API webhook events.
+ Managing Quick Replies - Serving user content with Direct Messages API.
+ Bot commands - The SnowBot was designed to work mainly with specific commands. 

### Handing webhook events <a id="managing-webhooks" class="tall">&nbsp;</a> 

The ```EventManager``` class is implemented in ```SnowBotDev/app/helpers/event_manager.rb```. The ```handle_event``` method examines the incoming (Direct Message) event and determines whether it is a Quick Reply response or a bot command.

```
def handle_event(events)

  events = JSON.parse(events)
  if events.key? ('direct_message_events')

    dm_events = events['direct_message_events']
    dm_events.each do |dm_event|

      if dm_event['type'] == 'message_create'

        #Is this a response? Test for the 'quick_reply_response' key.
        is_response = dm_event['message_create'] && dm_event['message_create']['message_data'] && dm_event['message_create']['message_data']                           ['quick_reply_response']

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

All non-Quick Reply responses are routed to this method. So, this is where you can get fancy with message parsing and building responses. This implementation is simplistic, and only looks for supported commands if the incoming message text is 12 characters or less. If longer than 12 characters, no response is attempted. 

```
	def handle_command(dm_event)

		#Since this DM is not a response to a QR, let's check for other 'action' commands

		request = dm_event['message_create']['message_data']['text']
		user_id = dm_event['message_create']['sender_id']
		

		if request.length <= COMMAND_MESSAGE_LIMIT and (request.downcase.include? 'bot' or request.downcase.include? 'home' or              request.downcase.include? 'main' or request.downcase.include? 'hello' or request.downcase.include? 'back')
			@DMSender.send_welcome_message(user_id)

end

```

## Adding bot functionality <a id="functionality" class="tall">&nbsp;</a> 

### Basic menu navigation <a id="navigation" class="tall">&nbsp;</a> 

The SnowBot is the third of a line of chatbot examples. About the only thing in common, code and menu wise, is that there are a set of navigation options that are typically tacked onto the end of a set of Quick Reply options. These navigation helpers can include things like 'back', 'home', 'about' and 'help' options. Regardless of a chatbot's focus, these are helpful, and generic, features that any chatbot can benefit from: 

* ⌂ Home - Returns users to the 'top' of the menu options.   

* ⬅ Back - Returns users to the 'parent' option of their current level. For example, you are viewing a snow report, the 'Back' option will return you to the resorts list. 

* ☔  Help - Returns static text of your choice. With the SnowBot, the help command returns a list of support bot commands. 

* ❓ Learn - Returns static text of your choice. With the SnowBot, the 'learn' command returns a project link, and provides third-party API credits.  

The SnowBot was written with a goal of having common code that can be easily ported to other new bots. A next step would be encapsulating these navigation details into it own portable class.  

Here is what the 'packaging' looks like for default options:

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

Here is where the help contents are built: ```generate_system_help(recipient_id)```

![](https://github.com/jimmoffitt/SnowBotDev/blob/master/docs/screenshots/help.jpg)


Back buttons require a bit more metadata to implement. 

Types: 'locations', 'links', 'playlists'

```
	option = {}
	option['label'] = '⬅ Back'
	option['description'] = 'Previous list...' if description
	option['metadata'] = "go_back #{type} "
```


```
  if response_metadata.include? 'go_back'

	type =  response_metadata['go_back'.length..-1].strip

	if type == 'links'
		@DMSender.send_links_list(user_id)
	elsif type == 'locations'
		@DMSender.send_locations_list(user_id)
	elsif type == 'playlists'
		@DMSender.send_playlists_list(user_id)
	end
```

### Serving option lists <a id="lists" class="tall">&nbsp;</a> 

The SnowBot serves up several curated lists:

+ Resort names for requesting snow reports.
+ Links to web sites that have a focus on snow research. 
+ Links to playlists with weather-related themes.

These lists are configured and loaded from the server side. For each list a 'resource' file is looked up, opened, parsed, and assembled into metadata for a Quick Reply option list. For example, when a user wants to request a snow report, they are presented a list of resorts to choose from. The resort names are loaded from a *placesOfInterest.csv* file that is placed in a SnowBotDev/app/config/data/ folder. 

Note that Quick Reply option lists are limited to 20 items. 

The mechanics of loading these resource files is encapsulated in ```SnowBotDev/app/helpers/get_resources.rb```.

The GenerateDirectMessageContent class is responsible for, as its name implies, generating content that is sent via Direct Messages. That class creates a GetResources object, which returns a set of resource arrays. 

```
@resources = {}
@resources = GetResources.new

@resources.locations_list
@resources.playlists_list
@resources.links_list

```
These resource arrays are loaded from these CSV files: 

+ SnowBotDev/app/config/data/locations/placesOfInterest.csv - Contents: display Name, longitude, latitude, Resort ID
+ SnowBotDev/app/config/data/links/links.csv - Contents: Display summary, URL, site description
  + Note that since link metadata can be long-form with commas, semi-colons are used as the delimiter.
+ SnowBotDev/app/config/data/music/playlists.csv - Contents: Display name, description, URL 

Since these resource files are loaded on-demand when a user request them, you can upload them to your server and they are updated on-the-fly. When the GetResources class loads these files, it will ignore any lines that start with the '#' characters, enabling you to include notes in the resource files.

The SnowBot also loads in a long list of photographs. These are not presented in a list, but instead are served randomly to the user. The GenerateDirectMessageContent accesses the photo list via:

```
 @resources.photos_list
```

The photo list is loaded from this CSV file:

+ SnowBotDev/app/config/data/photos/photos.csv - Contents: file name, description
  + Note that since the description can contain commas, semi-colons are used as the delimiter.

The actual photos need to be stored here: SnowBotDev/app/config/data/photos/*.jpg.

### Adding attachments to Direct Messages <a id="attachments" class="tall">&nbsp;</a> 

The SnowBot serves snow-related photographs by ['attaching' media to Direct Messages](https://developer.twitter.com/en/docs/direct-messages/message-attachments/guides/attaching-media). As discussed there, sending a Direct Message with media is a two-step process. First the photo or video is [uploaded to the Twitter platform at upload.twitter.com/1.1/media/upload](https://developer.twitter.com/en/docs/media/upload-media/api-reference/post-media-upload-init.html), then a corresponding media numeric ID is included when generating Direct Message JSON.  

Since we did not want to write new code for uploading photographs and generating a media IDs, we looked for a Ruby gem that could abstract away the details. There are many Ruby gems built for the Twitter platform, and the SnowBot integrates [this 'twitter' gem](https://github.com/sferik/twitter). 

The 'serving media' details are contained in two places:

+ ```SnowBotDev/app/helpers/twitter_api.rb``` - A wrapper around the *twitter* gem. For the SnowBot, the TwitterAPI class has a single ```get_media_id(media_path)``` method. The class also manages authenticating with the media upload API, loading in your Twitter app tokens. 
+ ```SnowBotDev/app/helpers/generate_direct_message_content.rb``` - When a user requests a snow photo, a photo is picked randomly from the list and a media ID is generated by passing the photo path to the TwitterAPI object:

```
media_id = @upload_client.upload(File.new(media_path))
```

That ID is then sent along with the JSON generated for the Direct Message. 


```
attachment['type'] = "media"
attachment['media']['id'] = media_id
message_data['attachment'] = attachment
message_data['text'] = message
event['event']['message_create']['message_data'] = message_data
return event.to_json
```

### Integrating third-party APIs <a id="other-apis" class="tall">&nbsp;</a> 

The SnowBot has two features that are driven by third-party APIs: requesting current weather conditions for a location of interest, and getting snow reports for a list of ski resorts. Integrating third-party APIs was pretty simple. 

For this demo, two APIs were integrated: weather data from [WeatherUnderground.com](https://www.wunderground.com/weather/api/) and snow reports from [SnoCountry.com](http://www.snocountry.com/). WeatherUnderground provides a self-service for generating an API key. For the snow reports I reached out to SnoCountry.com and they were kind enough to provide a key. For both APIs, a simple HTTP GET request is made with the API key passed in as a request parameter.

These authentication keys are loaded in from your execution environment keys. Depending on your development/deploy environment, these can be set in different places. When running from an IDE, these keys can be set in a run/debug configuration. When deploying to a cloud platform, such as Heroku, the keys are set as part of a web app's *settings*. 

Note that without your own API keys, these bot features will fail with authentication-related errors. The assumption is that you will want to integrate APIs of your interest. To help with that the third-party API details are encapsulated in two places:

+ ```SnowBotDev/app/helpers/third_party_request.rb```
  + Class was written to contain all the details of making these third-party API calls. This class provides two ```get_current_weather``` and ```get_resort_info``` methods. The ```get_current_weather``` method takes a point coordinate (lat and long) and includes that in the call to Weather Underground. The ```get_resort_info``` takes a *resort ID* and submits that to the SnoCountry.com API. 
  
+ ```SnowBotDev/app/helpers/generate_diect_message_content.rb```
  + When users request weather or snow information, these requests of the thirdparty_api object are made:
    +  ```weather_info = @thirdparty_api.get_current_weather(coordinates[1], coordinates[0])```
    +  ```resort_info = @thirdparty_api.get_resort_info(resort_id)```
    
The thirdparty_api object encapsulates the 'pretty' formating of the content coming back from these two APIs. The generate_direct_message_content class, by design, knows nothing of these details and simply sets the  ```message_data['text']``` attribute to what the third party class returns. 


## Other tips <a id="tips" class="tall">&nbsp;</a> 

### Call to action Tweets

Once your bot is deployed and tested, it's time to help users find it. One way to do that is to post a "call to action" Tweet that contains a "Send a DM" button. To do that, just include the following type of link, referencing the Twitter account ID of the chatbot. Note that these can be posted from any account, so spread the word to colleagues and friends and have them post on your behalf. 

```
https://twitter.com/messages/compose?recipient_id=906948460078698496
```

The SnowBot has such a Tweet pinned to the top of its timeline:

![](https://github.com/jimmoffitt/SnowBotDev/blob/master/docs/screenshots/cta_tweet.jpg)



### Asking users for location

