#POST requests to /webhooks/twitter arrive here.
#Twitter Account Activity API send events as POST requests with JSON payloads.

require 'json'
#Two helper classes... 
require_relative 'send_direct_message'

class EventManager
	#Design: Identifying explicit commands is easy and can restrict text length based on its own length.
	#        If you want to be more flexible,
	COMMAND_MESSAGE_LIMIT = 12	#Simplistic way to detect an incoming, short, 'commmand' DM.
	#This should be served up by 'resources' class:
	RESORT_REGIONS = ['Colorado', 'California', 'Utah', 'New England', 'Midwest', 'Canadian Rockies',' Australia and New Zealand', 'ID/NM/OR/WA/WY']
	
	attr_accessor :DMsender,
				   :commands #adding a command? Add to string array, then add "handling" code.

	def initialize
		puts 'Got an event, creating EventManager object to manage it...'
		@DMSender = SendDirectMessage.new

		@commands = %w(bot home main back photo pic see wx weather report reports resort resorts rpt top learn snow playlist music about help)

	end

	def handle_conversation(dm_event)
		# handle 'hi' and other check-ins by pointing to main menu.
		# A primitive attempt to make reasonable responses.
		#puts "----------------- \nConversation to parse: #{dm_event.to_json}"

		#TODO: this code will be moved to the "generate content" class.

		get_started_default = "* To kick off the SnowBot, send 'main' or 'menu'. \n* To get straight to the snow reports, send 'reports'."
        
        message = dm_event[:message_create][:message_data][:text]
        puts "User #{dm_event[:message_create][:sender_id]}: #{message}"

        if message.include? ("thanks")
           response = "You're welcome!"
        else
		   response = "Hello #{dm_event[:message_create][:sender_id]}."
        end

		puts "#{response} + \n + #{get_started_default}"

	end

	def handle_quick_reply(dm_event)

		#puts "QR to parse: #{dm_event}"

		response_metadata = dm_event[:message_create][:message_data][:quick_reply_response][:metadata]
		user_id = dm_event[:message_create][:sender_id]

		#puts "response_metadata: #{response_metadata}"

		#Default options
		if response_metadata == 'help'
			@DMSender.send_system_help(user_id)
		
		elsif response_metadata == 'learn_more'
			@DMSender.send_system_info(user_id)
		
		elsif response_metadata == 'return_home'
			#puts "Returning to home in event manager...."
			@DMSender.send_welcome_message(user_id)
			
		#Custom options	
		elsif response_metadata == 'see_photo'
			@DMSender.send_photo(user_id)

		elsif response_metadata == 'snow_report'
			#puts "Selected snow report..."
			@DMSender.send_locations_list(user_id, 'top')
		elsif response_metadata.include? 'region_choice'
			region = response_metadata['region_choice: '.length..-1]
			#puts "Parsing region, and we got: #{region}"
			@DMSender.send_locations_list(user_id, region)
		elsif response_metadata.include? 'location_choice'
			metadata = response_metadata['location_choice: '.length..-1]
			choice = metadata.split('|')[0]
			region = metadata.split('|')[1]
			#puts "Parsing resort choice and its region, and got: #{choice} and #{region}"
			@DMSender.send_location_info(user_id, choice, region)

		elsif response_metadata == 'snow_tweet'
			@DMSender.send_tweet(user_id)

		elsif response_metadata == 'snow_music'
			@DMSender.send_playlists_list(user_id)
		elsif response_metadata.include? 'playlist_choice'
			choice = response_metadata['playlist_choice: '.length..-1]
			@DMSender.send_playlist(user_id, choice)

		elsif response_metadata == 'learn_snow'
			@DMSender.send_links_list(user_id)
		elsif response_metadata.include? 'link_choice'
			choice = response_metadata['link_choice: '.length..-1]
			@DMSender.send_link(user_id, choice)

		elsif response_metadata.include? 'go_back'
			#puts "Got 'go back' response"

			type =  response_metadata['go_back'.length..-1].strip

			#puts "\n #{type} \n"

			if type == 'links'
				@DMSender.send_links_list(user_id)
			elsif type == 'top'
				@DMSender.send_locations_list(user_id, 'top')
			elsif RESORT_REGIONS.include? type
				@DMSender.send_locations_list(user_id, type)
			elsif type == 'playlists'
				@DMSender.send_playlists_list(user_id)
			end

		elsif response_metadata.include? 'location_choice'
			
			location_choice = response_metadata['location_choice: '.length..-1]

			#Get coordinates
			coordinates = []

			location_choice = "#{location_choice} (centered at #{coordinates[0]}, #{coordinates[1]} to be specific)"
			@DMSender.respond_to_location_choice(user_id, location_choice)

		else #we have an answer to one of the above.
			puts "UNHANDLED user response: #{response_metadata}"
		end
		
	end

	def handle_command(dm_event)

		#Since this DM is not a response to a QR, let's check for other 'action' commands

		#puts "In handle command..."
		#puts dm_event

		command = dm_event[:message_create][:message_data][:text]
		command = command.downcase
		user_id = dm_event[:message_create][:sender_id]

		#puts "command=#{command}"

		if (command.include? 'bot' or command.include? 'home' or command.include? 'main' or command.include? 'hello' or command.include? 'back' or command.include? 'hi')
			puts "Got home command"
			@DMSender.send_welcome_message(user_id)
		elsif (command.include? 'photo' or command.include? 'pic' or command.include? 'see')
			@DMSender.send_photo(user_id)
		elsif (command.include? 'wx' or command.include? 'weather')
			@DMSender.send_map(user_id)
		elsif (command.include? 'report' or command.include? 'resort' or command.include? 'rpt')
			@DMSender.send_locations_list(user_id, 'top')
		elsif	(command.include? 'tweet')
			@DMSender.send_tweet(user_id)
=begin Support go-to commands to sub menus?
		elsif (request.include? 'co' or request.include? 'colorado')
			@DMSender.send_locations_list(user_id, 'Colorado')
		elsif (request.include? 'ca' or request.include? 'california')
			@DMSender.send_locations_list(user_id, 'California')
		elsif (request.include? 'ut' or request.include? 'utah')
			@DMSender.send_locations_list(user_id, 'Utah')
		elsif (request.include? 'mid' or request.include? 'midwest')
			@DMSender.send_locations_list(user_id, 'Midwest')
=end
		elsif (command.include? 'learn')
			@DMSender.send_links_list(user_id)
		elsif (command.include? 'playlist' or command.include? 'music')
			@DMSender.send_playlists_list(user_id)	
		elsif (command.include? 'about')
			@DMSender.send_system_info(user_id)
		elsif (command.include? 'help')
			@DMSender.send_system_help(user_id)
		else
			# This is where you'd plug in more fancy message processing...
			#message = "I only support a basic set of commands, send 'help' to review those... "
			#@DMSender.send_custom_message(user_id, message)
			puts "Some unrecognized command?"
		end
	end

	def is_typing_indicator?(event)
		answer = event.key? (:direct_message_indicate_typing_events)
	end

	def sending_QR?(dm_event)
		answer = dm_event[:message_create] && dm_event[:message_create][:message_data] && dm_event[:message_create][:message_data][:quick_reply]
	end

	def is_QR_response?(dm_event)
		answer = false
		#puts "Checking is response? #{dm_event}"

		#Is this a response? Test for the 'quick_reply_response' key.
		answer = dm_event[:message_create] && dm_event[:message_create][:message_data] && dm_event[:message_create][:message_data][:quick_reply_response]
		if !answer
			answer = dm_event[:message_create] && dm_event[:message_create][:message_data] && dm_event[:message_create][:message_data][:quick_reply]
		end

		#puts "is_response? => #{answer}"

		answer

	end

	def is_command?(dm_event)
		answer = false
		#puts "Checking is command?"

		command = dm_event[:message_create][:message_data][:text]
		command = command.downcase

		if command.length <= COMMAND_MESSAGE_LIMIT and @commands.include? command
			answer = true
			#puts "got a command: #{command}"
		end

		answer

	end

	#responses are based on options' Quick Reply metadata settings.
	#pick_from_list, select_on_map, location list items (e.g. 'location_list_choice: Austin' or 'Fort Worth')
	#map_selection (triggers a fetch of the shared coordinates)

	def handle_event(payload)

		payload = JSON.parse(payload, symbolize_names: true)

		#puts "Parsed JSON into dictionary with symbol keys #{payload.to_json}"

		if payload.key? (:direct_message_indicate_typing_events)
		  puts "Someone is typing..."
		#Examine the payload and determine if this is a 'send QR' event, or a 'QR response', or a bot 'command' or ...
		elsif payload.key? (:direct_message_events) #Unpack whether this is an array of "direct_message_events" or a single incoming DM.

			dm_events = payload[:direct_message_events]
			puts "Have array of events to parse... Have #{dm_events.length} events..."

			dm_events.each do |dm_event|

 				if sending_QR? (dm_event)
					puts "Sending QR to user..."

				elsif is_QR_response?(dm_event)
					#puts "QR RESPONSE from event array"
					handle_quick_reply dm_event
				elsif is_command?(dm_event)
					#puts "COMMAND"
					handle_command(dm_event)
				else
					#puts "Seems this was not a command or QR. Would be good to log there for future responses... "
					handle_conversation dm_event
					# handle 'hi' and other check-ins by pointing to main menu.
					#
				end

			end
		elsif payload.key? (:message_create) and !payload.key? (:direct_message_events) #Received a single DM from a Bot user....
			puts "Got a single DM from a Bot user..."

			if is_QR_response?(payload)
				#puts "QR response"
				handle_quick_reply payload
			elsif is_command?(payload)
				handle_command(payload)
			else
				#puts "Seems this was not a command or QR. Would be good to log there for future responses... "
				#puts "attempt conversation, and at least provide a main menu hint"
				handle_conversation payload
			end
		else	 #Handle other events that are not part of direct_message_events

			#TODO: log this - and logs can be followed during demos.

			if payload[:favorite_events]
				puts "Got Favorite event..."
			elsif
			  puts "Hey, a unhandled Account Activity event has been send from the Twitter side... A new follower? A Tweet liked? "
				puts "Incoming JSON payload --------------------- \n #{payload} \n ----------------------------"
			end
		end
	end
end


#Testing
if __FILE__ == $0 #This script code is executed when running this file.

	eventManager = EventManager.new


  #User made a QR selection:
  #'Request snow report'
  dm_event = '{"for_user_id":"17200003","direct_message_events":[{"type":"message_create","id":"1076988274588020740","created_timestamp":"1545608988793","message_create":{"target":{"recipient_id":"1549688316"},"sender_id":"17200003","source_app_id":"13573608","message_data":{"text":"\u2744 Select your area of interest:","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]},"quick_reply":{"type":"options","options":[{"label":"\u2b05 Back","metadata":"go_back top "},{"label":"\u2302 Home","metadata":"return_home"}]}}}}],"apps":{"13573608":{"id":"13573608","name":"SnowmanBot","url":"http:\/\/twitter.com\/snowman"}},"users":{"17200003":{"id":"17200003","created_timestamp":"1225926397000","name":"\u2744\ufe0f\u2744\ufe0f\u2744\ufe0f\u2744\ufe0f\u2744\ufe0f\u2744\ufe0f\u2744\ufe0f\u2744\ufe0f","screen_name":"snowman","location":"MN \u21e8 all over \u21e8 CO","description":"family, travel, music, snow, urban farming, rain, photography, coding, weather, clouds, snow, hydrology, early-warning systems, snow. From MN, live in CO.","protected":false,"verified":false,"followers_count":935,"friends_count":497,"statuses_count":2121,"profile_image_url":"http:\/\/pbs.twimg.com\/profile_images\/697445972402540546\/2CYK3PWX_normal.jpg","profile_image_url_https":"https:\/\/pbs.twimg.com\/profile_images\/697445972402540546\/2CYK3PWX_normal.jpg"},"1549688316":{"id":"1549688316","created_timestamp":"1372305745423","name":"#OnWard","screen_name":"elRealJimbo","location":"high plains desert","description":"I\'d rather be skiing","protected":false,"verified":false,"followers_count":24,"friends_count":102,"statuses_count":73,"profile_image_url":"http:\/\/pbs.twimg.com\/profile_images\/901552230205079552\/TGMIk1rO_normal.jpg","profile_image_url_https":"https:\/\/pbs.twimg.com\/profile_images\/901552230205079552\/TGMIk1rO_normal.jpg"}}}'

  #Serving main menu
  #dm_event ='{"for_user_id":"17200003","direct_message_events":[{"type":"message_create","id":"1076989222777548804","created_timestamp":"1545609214859","message_create":{"target":{"recipient_id":"1549688316"},"sender_id":"17200003","source_app_id":"13573608","message_data":{"text":"\u2744 Hi again...","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]},"quick_reply":{"type":"options","options":[{"label":"\u2744 See snow picture \ud83d\udcf7","metadata":"see_photo","description":"Check out a random snow related photo..."},{"label":"\u2744 Request snow report","metadata":"snow_report","description":"SnoCountry reports for select areas."},{"label":"\u2744 See (deep) snow Tweet of the day","metadata":"snow_tweet","description":"Most engaged Tweet from last 24 hours."},{"label":"\u2744 Learn something new about snow","metadata":"learn_snow","description":"Other than it is fun to slide on..."},{"label":"\u2744 Get geo, weather themed playlist","metadata":"snow_music","description":"Carefully curated Spotify playlists..."},{"label":"\u2753 Learn more about this system","metadata":"learn_more","description":"Including a link to underlying code..."},{"label":"\u2614 Help","metadata":"help","description":"Help with system commands"},{"label":"\u2302 Home","metadata":"return_home","description":"Go back home"}]}}}}],"apps":{"13573608":{"id":"13573608","name":"SnowmanBot","url":"http:\/\/twitter.com\/snowman"}},"users":{"17200003":{"id":"17200003","created_timestamp":"1225926397000","name":"\u2744\ufe0f\u2744\ufe0f\u2744\ufe0f\u2744\ufe0f\u2744\ufe0f\u2744\ufe0f\u2744\ufe0f\u2744\ufe0f","screen_name":"snowman","location":"MN \u21e8 all over \u21e8 CO","description":"family, travel, music, snow, urban farming, rain, photography, coding, weather, clouds, snow, hydrology, early-warning systems, snow. From MN, live in CO.","protected":false,"verified":false,"followers_count":935,"friends_count":497,"statuses_count":2121,"profile_image_url":"http:\/\/pbs.twimg.com\/profile_images\/697445972402540546\/2CYK3PWX_normal.jpg","profile_image_url_https":"https:\/\/pbs.twimg.com\/profile_images\/697445972402540546\/2CYK3PWX_normal.jpg"},"1549688316":{"id":"1549688316","created_timestamp":"1372305745423","name":"#OnWard","screen_name":"elRealJimbo","location":"high plains desert","description":"I\'d rather be skiing","protected":false,"verified":false,"followers_count":24,"friends_count":102,"statuses_count":73,"profile_image_url":"http:\/\/pbs.twimg.com\/profile_images\/901552230205079552\/TGMIk1rO_normal.jpg","profile_image_url_https":"https:\/\/pbs.twimg.com\/profile_images\/901552230205079552\/TGMIk1rO_normal.jpg"}}}'


  #"message_data": {"text": "\u2744 Hi again...",r
	# dm_event = '{"for_user_id":"17200003","direct_message_events":[{"type":"message_create","id":"1076620149241786373","created_timestamp":"1545521220871","message_create":{"target":{"recipient_id":"1549688316"},"sender_id":"17200003","souce_app_id":"13573608","message_data":{"text":"\u2744 Hi again...","entities":{"hashtags":[],"symbols":[],"user_mentions":[],"urls":[]},"quick_reply":{"type":"options","options":[{"label":"\u2744 See snow picture \ud83d\udcf7","metadata":"see_photo","description":"Check out a random snow related photo..."},{"label":"\u2744 Request snow report","metadata":"snow_report","description":"SnoCountry reports for select areas."},{"label":"\u2744 See (deep) snow Tweet of the day","metadata":"snow_tweet","description":"Most engaged Tweet from last 24 hours."},{"label":"\u2744 Learn something new about snow","metadata":"learn_snow","description":"Other than it is fun to slide on..."},{"label":"\u2744 Get geo, weather themed playlist","metadata":"snow_music","description":"Carefully curated Spotify playlists..."},{"label":"\u2753 Learn more about this system","metadata":"learn_more","description":"Including a link to underlying code..."},{"label":"\u2614 Help","metadata":"help","description":"Help with system commands"},{"label":"\u2302 Home","metadata":"return_home","description":"Go back home"}]}}}}],"apps":{"13573608":{"id":"13573608","name":"SnowmanBot","url":"http:\/\/twitter.com\/snowman"}},"users":{"17200003":{"id":"17200003","created_timestamp":"1225926397000","name":"\u2744\ufe0f\u2744\ufe0f\u2744\ufe0f\u2744\ufe0f\u2744\ufe0f\u2744\ufe0f\u2744\ufe0f\u2744\ufe0f","screen_name":"snowman","location":"MN \u21e8 all over \u21e8 CO","description":"family, travel, music, snow, urban farming, rain, photography, coding, weather, clouds, snow, hydrology, early-warning systems, snow. From MN, live in CO.","protected":false,"verified":false,"followers_count":937,"friends_count":497,"statuses_count":2121,"profile_image_url":"http:\/\/pbs.twimg.com\/profile_images\/697445972402540546\/2CYK3PWX_normal.jpg","profile_image_url_https":"https:\/\/pbs.twimg.com\/profile_images\/697445972402540546\/2CYK3PWX_normal.jpg"},"1549688316":{"id":"1549688316","created_timestamp":"1372305745423","name":"#OnWard","screen_name":"elRealJimbo","location":"high plains desert","description":"I\'d rather be skiing","protected":false,"verified":false,"followers_count":24,"friends_count":102,"statuses_count":73,"profile_image_url":"http:\/\/pbs.twimg.com\/profile_images\/901552230205079552\/TGMIk1rO_normal.jpg","profile_image_url_https":"https:\/\/pbs.twimg.com\/profile_images\/901552230205079552\/TGMIk1rO_normal.jpg"}}}'

  #Command: "message_create":"message_data":"text": "home"
  #dm_event =  '{"type":"message_create", "id":"1076909801097981956", "created_timestamp":"1545590279255", "message_create":{"target":{"recipient_id":"17200003"}, "sender_id":"1549688316", "message_data":{"text":"Home", "entities":{"hashtags":[], "symbols":[], "user_mentions":[], "urls":[]}}}}'

  eventManager.handle_event(dm_event)

end
