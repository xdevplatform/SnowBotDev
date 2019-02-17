require 'twitter' #Opens doors to the rest of the standard Twitter APIs.
                  #https://github.com/sferik/twitter/blob/master/examples/Configuration.md

class TwitterAPI

	attr_accessor :keys,
	              :twitter_client,
	              :base_url, # 'https://api.twitter.com/' or 'upload.twitter.com' or ?
	              :uri_path #No default.

		def initialize()

			#puts "Creating Twitter (public) API object."

      @base_url = 'upload.twitter.com'
			@uri_path = '/1.1/media/upload'

			#Get Twitter App keys and tokens via the ENV{} hash.
			@keys = {}

			@keys['consumer_key'] = ENV['CONSUMER_KEY']
			@keys['consumer_secret'] = ENV['CONSUMER_SECRET']
			@keys['access_token'] = ENV['ACCESS_TOKEN']
			@keys['access_token_secret'] = ENV['ACCESS_TOKEN_SECRET']

			@twitter_client = Twitter::REST::Client.new(@keys)
	
	end
  
	def get_media_id(media_path)
		
		puts "Value of media: #{media_path}"

		media_id = nil

		if media_path != '' and not media_path.nil?
			#puts "Calling upload with #{media_path}"
      media_id = @twitter_client.upload(File.new(media_path))
		else
			media_id = nil
		end	

		media_id
	
	end

	def get_user_handle(id)

		user = @twitter_client.user(id.to_i)
		handle = user.to_h[:screen_name]

		handle
	end

end

