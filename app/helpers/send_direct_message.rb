require 'json'
require 'csv'
require 'pathname'
require_relative 'api_oauth_request'
require_relative 'generate_direct_message_content'

class SendDirectMessage

	attr_accessor :dm,            #Object that manages DM API requests.
	              :content,
	              :sender

	def initialize

		puts "Creating SendDirectMessage object."
		
		@dm = ApiOauthRequest.new

		@dm.uri_path = '/1.1/direct_messages'
		@dm.get_api_access

		@content = GenerateDirectMessageContent.new

	end

	def send_snow_day(recipient_id)
		#Demonstrates easy way to stub out future functionality until customer 'generate content' method is written.
		dm_content = @content.generate_snow_day(recipient_id)
		send_direct_message(dm_content)
	end
	
	def send_photo(recipient_id)
		dm_content = @content.generate_random_photo(recipient_id)
		send_direct_message(dm_content)
	end
	
	#Weather data is map based.
	def send_map(recipient_id)
		dm_content = @content.generate_location_map(recipient_id)
		send_direct_message(dm_content)
	end

	def send_weather_info(recipient_id, coordinates)
		dm_content = @content.generate_weather_info(recipient_id, coordinates)
		send_direct_message(dm_content)
	end
	
  #Links are list based, and currently app has just one links list. 
	def send_links_list(recipient_id)
		dm_content = @content.generate_link_list(recipient_id)
		send_direct_message(dm_content)
	end

	def send_link(recipient_id, choice)
		dm_content = @content.generate_link(recipient_id, choice)
		send_direct_message(dm_content)
	end

	#Snow reports are list based, and currently app has just one location list.
	def send_locations_list(recipient_id)
		dm_content = @content.generate_location_list(recipient_id)
		send_direct_message(dm_content)
	end

	def send_location_info(recipient_id, choice)
		dm_content = @content.generate_location_info(recipient_id, choice)
		send_direct_message(dm_content)
	end

	#Links are list based, and currently app has just one links list.
	def send_playlists_list(recipient_id)
		dm_content = @content.generate_playlist_list(recipient_id)
		send_direct_message(dm_content)
	end

	def send_playlist(recipient_id, choice)
		dm_content = @content.generate_playlist(recipient_id, choice)
		send_direct_message(dm_content)
	end
	
	# App Generic? All apps have these by default?

	def send_system_info(recipient_id)
		dm_content = @content.generate_system_info(recipient_id)
		send_direct_message(dm_content)
	end
	
	def send_system_help(recipient_id)
		dm_content = @content.generate_system_help(recipient_id)
		send_direct_message(dm_content)
	end

	def send_status(recipient_id, message)
		dm_content = @content.generate_message(recipient_id, message)
		send_direct_message(dm_content)
	end

	def send_welcome_message(recipient_id)
		dm_content = @content.generate_welcome_message(recipient_id)
		
		puts dm_content
		
		send_direct_message(dm_content)
	end

	#Send a DM back to user.
	#https://dev.twitter.com/rest/reference/post/direct_messages/events/new
	def send_direct_message(message)

		uri_path = "#{@dm.uri_path}/events/new.json"
		response = @dm.make_post_request(uri_path, message)

		#Currently, not returning anything... Errors reported in POST request code.
		response

	end

end

#And here you can unit test sending different types of DMs... send map? attach media?

if __FILE__ == $0 #This script code is executed when running this file.

	sender = SendDirectMessage.new
	#sender.send_map(944480690)
	#sender.send_photo(944480690)

	#sender.send_links_list(944480690)
	#sender.respond_with_link(944480690,'NASA')
	
	sender.send_location_info(944480690,"The Remarkables NZ")

end