#POST requests to /webhooks/twitter arrive here.
#Twitter Account Activity API send events as POST requests with DM JSON payloads.

require 'json'
#Two helper classes... 
require_relative 'send_direct_message'

class EventManager
	#Design: Identifying explicit commands is easy and can restrict text length based on its own length.
	#        If you want to be more flexible,
	COMMAND_MESSAGE_LIMIT = 12	#Simplistic way to detect an incoming, short, 'commmand' DM.
	
	attr_accessor :DMsender

	def initialize
		puts 'Creating EventManager object'
		@DMSender = SendDirectMessage.new
	end

	def handle_quick_reply(dm_event)

		response_metadata = dm_event['message_create']['message_data']['quick_reply_response']['metadata']
		user_id = dm_event['message_create']['sender_id']

		#Default options
		if response_metadata == 'help'
			@DMSender.send_system_help(user_id)
		elsif response_metadata == 'learn_more'
			@DMSender.send_system_info(user_id)
		elsif response_metadata == 'return_home'
			puts "Returning to home in event manager...."
			@DMSender.send_welcome_message(user_id)
			
		#Custom options	
		elsif response_metadata == 'see_photo'
			@DMSender.send_photo(user_id)
	
			elsif response_metadata.include? 'weather_info'
			@DMSender.send_map(user_id)

		elsif response_metadata == 'map_selection'
			#Do we have a Twitter Place or exact coordinates....?
			location_type = dm_event['message_create']['message_data']['attachment']['location']['type']
			if location_type == 'shared_coordinate'
				coordinates = dm_event['message_create']['message_data']['attachment']['location']['shared_coordinate']['coordinates']['coordinates']
			else
				coordinates = dm_event['message_create']['message_data']['attachment']['location']['shared_place']['place']['centroid']
			end
			@DMSender.send_weather_info(user_id, coordinates)

		elsif response_metadata == 'learn_snow'
			@DMSender.send_links_list(user_id)

		elsif response_metadata == 'snow_music'
			@DMSender.send_playlists_list(user_id)

		elsif response_metadata.include? 'link_choice'
			choice = response_metadata['link_choice: '.length..-1]
			@DMSender.send_link(user_id, choice)

		elsif response_metadata.include? 'playlist_choice'
			choice = response_metadata['playlist_choice: '.length..-1]
			@DMSender.send_playlist(user_id, choice)

		elsif response_metadata == 'snow_report'
			@DMSender.send_locations_list(user_id)
			
	#TODO - IMPLEMENT	------------------------------------------

		elsif response_metadata == 'snow_day'
			@DMSender.send_snow_day(user_id)
	
		elsif response_metadata.include? 'location_choice'
			choice = response_metadata['location_choice: '.length..-1]
			@DMSender.send_location_info(user_id, choice)

		elsif response_metadata.include? 'go_back'
			puts "Parse #{response_metadata.strip} and point there."
			
			type =  response_metadata['go_back'.length..-1].strip

			puts "------------------> type = #{type}"
			
			if type == 'links'
				@DMSender.send_links_list(user_id)
			elsif type == 'locations'
				@DMSender.send_locations_list(user_id)
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

		request = dm_event['message_create']['message_data']['text']
		user_id = dm_event['message_create']['sender_id']
		
		#puts "Request with command: #{request}"

		if request.length <= COMMAND_MESSAGE_LIMIT and (request.downcase.include? 'bot' or request.downcase.include? 'home' or request.downcase.include? 'main' or request.downcase.include? 'hello' or request.downcase.include? 'back')
			@DMSender.send_welcome_message(user_id)
		elsif request.length <= COMMAND_MESSAGE_LIMIT and (request.downcase.include? 'photo' or request.downcase.include? 'pic' or request.downcase.include? 'see')
			@DMSender.send_photo(user_id)
		elsif request.length <= COMMAND_MESSAGE_LIMIT and (request.downcase.include? 'wx' or request.downcase.include? 'weather')
			@DMSender.send_map(user_id)
		elsif request.length <= COMMAND_MESSAGE_LIMIT and (request.downcase.include? 'report' or request.downcase.include? 'resort')
			@DMSender.send_locations_list(user_id)
		elsif request.length <= COMMAND_MESSAGE_LIMIT and (request.downcase.include? 'day')
			@DMSender.send_snow_day(user_id)
		elsif request.length <= COMMAND_MESSAGE_LIMIT and (request.downcase.include? 'learn')
			@DMSender.send_links_list(user_id)
		elsif request.length <= COMMAND_MESSAGE_LIMIT and (request.downcase.include? 'playlist' or request.downcase.include? 'music')
			@DMSender.send_playlists_list(user_id)	
		elsif request.length <= COMMAND_MESSAGE_LIMIT and (request.downcase.include? 'about')
			@DMSender.send_system_info(user_id)
		elsif request.length <= COMMAND_MESSAGE_LIMIT and (request.downcase.include? 'help')
			@DMSender.send_system_help(user_id)
		else
			#"Listen, I only understand a few commands like: learn, about, help"
		end
	end

	#responses are based on options' Quick Reply metadata settings.
	#pick_from_list, select_on_map, location list items (e.g. 'location_list_choice: Austin' or 'Fort Worth')
	#map_selection (triggers a fetch of the shared coordinates)

	def handle_event(events)

		#puts "Event handler processing: #{events}"

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
				else
					puts "Hey a new, unhandled type has been implemented on the Twitter side."
				end
			end
		else
			puts "Received test JSON."
		end
	end
end
