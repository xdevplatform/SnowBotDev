#Generates all content for bot Direct Messages.
#Many responses include configuration metadata/resources, such as photos, links, and location list.
#These metadata are loading from local files.
#Direct Messages with media require a side call to Twitter upload endpoint, so this class uses a Twitter API object. 

require_relative 'twitter_api'          #Hooks to Twitter Public APIs via 'twitter' gem. 
require_relative 'third_party_request'  #Hooks to third-party APIs.
require_relative 'get_resources'        #Loads local resources used to present DM menu options and photos to users.

class GenerateDirectMessageContent
	
	VERSION = 0.888
	BOT_NAME = 'SnowBotDev'
	BOT_CHAR = '❄'

	attr_accessor :TwitterAPI, 
		      :resources,
		      :thirdparty_api

	def initialize(setup=nil) #'Setup Welcome Message' script using this too, but does not require many helper objects.

		#puts "Creating GenerateDirectMessageContent object."

		if setup.nil?
			@twitter_api = TwitterAPI.new
			@resources = GetResources.new
			@thirdparty_api = ThirdPartyRequest.new
		end

	end

	#================================================================
	def generate_random_photo(recipient_id)

		#Build DM content.
		event = {}
		event['event'] = message_create_header(recipient_id)
		
		message_data = {}
		
		#Select photo(at random).
		photo = @resources.photos_list.sample
		message = photo[1]
		message_data['text'] = message
		
		#Confirm photo file exists
		photo_file = "#{@resources.photos_home}/#{photo[0]}"
		
		if File.file? photo_file
			media_id = @twitter_api.get_media_id(photo_file)

			attachment = {}
			attachment['type'] = "media"
			attachment['media'] = {}
			attachment['media']['id'] = media_id

			message_data['attachment'] = attachment
			
		else
			media_id = nil
			message = "Sorry, could not load photo: #{photo_file}."
		end

		message_data['quick_reply'] = {}
		message_data['quick_reply']['type'] = 'options'

		options = []
		options = build_photo_option
		options += build_home_option('with_description')

		message_data['quick_reply']['options'] = options
		
		event['event']['message_create']['message_data'] = message_data

		event.to_json

	end

  def generate_playlist_list(recipient_id)

	  event = {}
	  event['event'] = message_create_header(recipient_id)

	  message_data = {}
	  message_data['text'] = 'Select a playlist:'

	  message_data['quick_reply'] = {}
	  message_data['quick_reply']['type'] = 'options'

	  options = []

	  @resources.playlists_list.each do |item|
		  if item.count > 0
			  option = {}
			  option['label'] = "#{BOT_CHAR} " + item[0]
			  option['metadata'] = "playlist_choice: #{item[0]}"
			  option['description'] = item[1]
			  options << option
		  end
	  end

	  options += build_home_option('with description')

	  message_data['quick_reply']['options'] = options

	  event['event']['message_create']['message_data'] = message_data
	  event.to_json

  end
  
  def generate_playlist(recipient_id, playlist_choice)

	  #Build link response.
	  message = "Issue with sharing #{playlist_choice} playlist..."
	  @resources.playlists_list.each do |playlist|
		  if playlist[0] == playlist_choice
			  message = playlist[2]
			  break
		  end
	  end

	  event = {}
	  event['event'] = message_create_header(recipient_id)

	  message_data = {}
	  message_data['text'] = message

	  message_data['quick_reply'] = {}
	  message_data['quick_reply']['type'] = 'options'

	  options = build_back_option 'playlists'
	  options += build_home_option

	  message_data['quick_reply']['options'] = options
	  event['event']['message_create']['message_data'] = message_data
	  event.to_json
  end

  def generate_link_list(recipient_id)

		event = {}
		event['event'] = message_create_header(recipient_id)

		message_data = {}
		message_data['text'] = 'Select a link:'

		message_data['quick_reply'] = {}
		message_data['quick_reply']['type'] = 'options'

		options = []
		
		@resources.links_list.each do |item|
			if item.count > 0 
				option = {}
				option['label'] = "#{BOT_CHAR} " + item[0]
				option['metadata'] = "link_choice: #{item[0]}"
				option['description'] = item[1]
				options << option
			end
		end
		
		options += build_home_option('with description')

		message_data['quick_reply']['options'] = options

		event['event']['message_create']['message_data'] = message_data
		event.to_json

	end

  def generate_link(recipient_id, link_choice)

		#Build link response.
		message = "Issue with displaying #{link_choice}..."
		@resources.links_list.each do |link|
			if link[0] == link_choice
				message = "#{link[2]}\nSummary:\n#{link[3]}"
				break
			end
		end
		event = {}
	  event['event'] = message_create_header(recipient_id)

	  message_data = {}
	  message_data['text'] = message

	  message_data['quick_reply'] = {}
	  message_data['quick_reply']['type'] = 'options'

		options = build_back_option 'links'
	  options += build_home_option

	  message_data['quick_reply']['options'] = options
	  event['event']['message_create']['message_data'] = message_data
	  event.to_json
		
  end

	#Saved for when we have a workaround for getting user location coordinates.
  def generate_weather_info(recipient_id, coordinates)

	  weather_info = @thirdparty_api.get_current_weather(coordinates[1], coordinates[0])

	  event = {}
	  event['event'] = message_create_header(recipient_id)

	  message_data = {}
	  message_data['text'] = weather_info

	  message_data['quick_reply'] = {}
	  message_data['quick_reply']['type'] = 'options'
	  
	  options = []
	  
	  options += build_home_option

	  message_data['quick_reply']['options'] = options
	  
	  event['event']['message_create']['message_data'] = message_data
	  event.to_json

  end

  #Generates Quick Reply for presenting user a Location List via Direct Message.
	#https://dev.twitter.com/rest/direct-messages/quick-replies/options
	def generate_location_list(recipient_id)

		event = {}
		event['event'] = message_create_header(recipient_id)

		message_data = {}
		message_data['text'] = "#{BOT_CHAR} Select your area of interest:"

		message_data['quick_reply'] = {}
		message_data['quick_reply']['type'] = 'options'

		options = []

		@resources.locations_list.each do |item|
			if item.count > 0
				option = {}
				option['label'] = "#{BOT_CHAR} " + item[0]
				option['metadata'] = "location_choice: #{item[0].strip}"
				#option['description'] = 'what is there to say here?'
				options << option
			end
		end
		
		options += build_home_option

		message_data['quick_reply']['options'] = options

		event['event']['message_create']['message_data'] = message_data
		event.to_json

	end

  def generate_location_info(recipient_id, location_name)

		resort_id = 0
	  @resources.locations_list.each do |location|
		  if location[0] == location_name
				resort_id = location[3]
				break
		  end  
	  end

		resort_info   = @thirdparty_api.get_resort_info(resort_id)

	  event = {}
	  event['event'] = message_create_header(recipient_id)

	  message_data = {}
	  message_data['text'] = resort_info

	  message_data['quick_reply'] = {}
	  message_data['quick_reply']['type'] = 'options'

		options = build_back_option 'locations'
	  options = options + build_home_option  #('with_description')

	  message_data['quick_reply']['options'] = options
	  event['event']['message_create']['message_data'] = message_data
	  event.to_json

  end

	#=====================================================================================
	
	def generate_greeting

		greeting = "#{BOT_CHAR} Welcome to #{BOT_NAME} (ver. #{VERSION}) #{BOT_CHAR}. Send 'home' for main menu and 'help' for a list of supported commands."
		greeting

	end

	def generate_main_message
		greeting = ''
		greeting = generate_greeting
		greeting =+ "#{BOT_CHAR} Thanks for stopping by... #{BOT_CHAR}"

	end

	def message_create_header(recipient_id)

		header = {}

		header['type'] = 'message_create'
		header['message_create'] = {}
		header['message_create']['target'] = {}
		header['message_create']['target']['recipient_id'] = "#{recipient_id}"

		header

	end

	def generate_welcome_message_default

		message = {}
		message['welcome_message'] = {}
		message['welcome_message']['message_data'] = {}
		message['welcome_message']['message_data']['text'] = generate_greeting

		message['welcome_message']['message_data']['quick_reply'] = generate_welcome_options

		message.to_json

	end

	#Users are shown this when returning home... A way to 're-start' dialogs...
	#https://dev.twitter.com/rest/reference/post/direct_messages/welcome_messages/new
	def generate_welcome_message(recipient_id)
		
		event = {}
		event['event'] = message_create_header(recipient_id)

		message_data = {}
		message_data['text'] = "#{BOT_CHAR} Welcome back..." #generate_main_message

		message_data['quick_reply'] = generate_welcome_options

		event['event']['message_create']['message_data'] = message_data

		event.to_json

	end
 
  def generate_system_info(recipient_id)

	  message_text = "#{BOT_CHAR} This is a snow bot (version #{VERSION})... It's kinda simple, kinda not... \n " +
		               "See here for project code and tutorial: https://github.com/twitterdev/SnowBotDev/wiki. \n" +
	                 "\n" + 
	                 "Credits: \n" + 
	                 "Snow reports are provided with an API from @SnoCountryCom.\n" +
	                 "Weather data are provided with an API from Weather Underground.\n"
	  

	  #Build DM content.
	  event = {}
	  event['event'] = message_create_header(recipient_id)

	  message_data = {}
	  message_data['text'] = message_text

	  message_data['quick_reply'] = {}
	  message_data['quick_reply']['type'] = 'options'

	  options = build_home_option

	  message_data['quick_reply']['options'] = options

	  event['event']['message_create']['message_data'] = message_data
	  event.to_json
  end

  def generate_system_help(recipient_id)

	  message_text = "Several commands are supported: \n \n" + 
                "#{BOT_CHAR} ⇨ Main menu \n  send: 'bot', 'home', 'main' \n " +
                "#{BOT_CHAR} ⇨ See photo \n  send: 'photo', 'pic' \n  " +
		            "#{BOT_CHAR} ⇨ Get resort snow report \n  send: 'report', 'resort' \n    via http://feeds.snocountry.net/conditions \n "  +
                "#{BOT_CHAR} ⇨ Learn about snow \n  send: 'learn', 'link' \n " +
	              "#{BOT_CHAR} ⇨ Get playlist \n  send: 'playlist', 'music' \n " +
	              "#{BOT_CHAR} ⇨ Learn about the #{BOT_NAME} \n   send: 'about' \n " +
	              "#{BOT_CHAR} ⇨ Review these commands \n  send: 'help' \n "

	  #Build DM content.
	  event = {}
	  event['event'] = message_create_header(recipient_id)

	  message_data = {}
	  message_data['text'] = message_text

	  message_data['quick_reply'] = {}
	  message_data['quick_reply']['type'] = 'options'

	  options = []
	  #Not including 'description' option attributes.

	  options = build_home_option

	  message_data['quick_reply']['options'] = options

	  event['event']['message_create']['message_data'] = message_data
	  event.to_json
  end
	
	#=====================================================================================

	def build_custom_options

		options = []

		option = {}
		option['label'] = "#{BOT_CHAR} See snow picture 📷"
		option['description'] = 'Check out a random snow related photo...'
		option['metadata'] = 'see_photo'
		options << option

		option = {}
		option['label'] = "#{BOT_CHAR} Request snow report"
		option['description'] = 'SnoCountry reports for select areas.'
		option['metadata'] = 'snow_report'
		options << option

		option = {}
		option['label'] = "#{BOT_CHAR} Learn something new about snow"
		option['description'] = 'Other than it is fun to slide on...'
		option['metadata'] = 'learn_snow'
		options << option

	  option = {}
		option['label'] = "#{BOT_CHAR} Get geo, weather themed playlist"
		option['description'] = 'Carefully curated Spotify playlists...'
		option['metadata'] = 'snow_music'
		options << option

		options

	end

	def build_default_options

		options = []

		option = {}
		option['label'] = '❓ Learn more about this system'
		option['description'] = 'Including a link to underlying code...'
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

  def build_photo_option

	  options = []

	  option = {}
	  option['label'] = "#{BOT_CHAR} Another 📷 "
	  option['description'] = '📷Another snow photo'
	  option['metadata'] = "see_photo"
	  options << option

	  options

  end
  
  #Types: list choices, going back to list. links, resorts
	def build_back_option(type=nil, description=nil)

		options = []

		option = {}
		option['label'] = '⬅ Back'
		option['description'] = 'Previous list...' if description
		option['metadata'] = "go_back #{type} "

		options << option

		options
		
  end
  
	def build_home_option(description=nil)
		
		options = []

		option = {}
		option['label'] = '⌂ Home'
		option['description'] = 'Go back home' if description
		option['metadata'] = "return_home"
		options << option

		options

	end

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

  #=============================================================

	#https://dev.twitter.com/rest/reference/post/direct_messages/welcome_messages/new
	def generate_system_maintenance_welcome

		message = {}
		message['welcome_message'] = {}
		message['welcome_message']['message_data'] = {}
		message['welcome_message']['message_data']['text'] = "System going under maintenance... Come back soon..."

		message.to_json

	end

	#https://dev.twitter.com/rest/reference/post/direct_messages/welcome_messages/new
	def generate_message(recipient_id, message)

		#Build DM content.
		event = {}
		event['event'] = message_create_header(recipient_id)

		message_data = {}
		message_data['text'] = message

		event['event']['message_create']['message_data'] = message_data

		#TODO: Add home option? options = options + build_home_option

		event.to_json
	end

end
