require 'twitter' #Opens doors to rest of public Twitter APIs.
#https://github.com/sferik/twitter/blob/master/examples/Configuration.md

#tl;dr This class provides a method for uploading a photo. @SnowBotDev chatbot has a feature to view a photo attached to a Direct Message. The 'twitter' gem does so much more, but that is all this bot needed. 

class TwitterAPI

	attr_accessor :keys,
	              :upload_client,
	              :base_url, # 'https://api.twitter.com/' or 'upload.twitter.com' or ?
	              :uri_path #No default.

		def initialize()

			#puts "Creating Twitter (public) API object."

      @base_url = 'upload.twitter.com'
			@uri_path = '/1.1/media/upload'

			#Get Twitter App keys and tokens. Read from 'config.yaml' if provided, or if running on Heroku, pull from the
			#'Config Variables' via the ENV{} hash.
			@keys = {}

			@keys['consumer_key'] = ENV['CONSUMER_KEY']
			@keys['consumer_secret'] = ENV['CONSUMER_SECRET']
			@keys['access_token'] = ENV['ACCESS_TOKEN']
			@keys['access_token_secret'] = ENV['ACCESS_TOKEN_SECRET']

			@upload_client = Twitter::REST::Client.new(@keys)
	
	end
  
	def get_media_id(media_path)
		
		#puts "Value of media: #{media_path}"

		media_id = nil

		if media_path != '' and not media_path.nil?
			puts "Calling upload with #{media_path}"
      media_id = @upload_client.upload(File.new(media_path))
		else
			media_id = nil
		end	

		media_id
	
  end

end

