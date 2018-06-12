#With many Twitter (Public) APIs, you can just use something like the 'twitter' gem.
#This example instead builds requests making the 'oauth' gem, and is not Twitter specific.

require 'json'
require 'oauth'
require 'yaml'

class ApiOauthRequest

	HEADERS = {"content-type" => "application/json"} #Suggested set? Any?

	attr_accessor :keys,
	              :twitter_api,
	              :base_url #Default: 'https://api.twitter.com/'


	def initialize(config=nil)

		@base_url = 'https://api.twitter.com'

		#'Config Variables' via the ENV{} hash.
		@keys = {}

		if config.nil?
      #Load keys from ENV.
			@keys['consumer_key'] = ENV['CONSUMER_KEY']
			@keys['consumer_secret'] = ENV['CONSUMER_SECRET']
			@keys['access_token'] = ENV['ACCESS_TOKEN']
			@keys['access_token_secret'] = ENV['ACCESS_TOKEN_SECRET']
		else
			#Load from config file.
			@keys = YAML::load_file(config)
		end

  end

  #API client object is created with the @base_url context, then individual requests are made with specific URI paths passed in.

	def get_api_access
		consumer = OAuth::Consumer.new(@keys['consumer_key'], @keys['consumer_secret'], {:site => @base_url})
		token = {:oauth_token => @keys['access_token'],
		         :oauth_token_secret => @keys['access_token_secret']
		}

		@twitter_api = OAuth::AccessToken.from_hash(consumer, token)

  end

  def make_post_request(uri_path, request)
		get_api_access if @twitter_api.nil? #token timeout?

		response = @twitter_api.post(uri_path, request, HEADERS)

		if response.code.to_i >= 300
			puts "POST ERROR occurred with #{uri_path}, request: #{request} "
			puts "Error code: #{response.code} #{response}"
			puts "Error Message: #{response.body}"
		end

		if response.body.nil? #Some successful API calls have nil response bodies, but have 2## response codes.
			 return response.code #Examples include 'set subscription', 'get subscription', and 'delete subscription'
		else
			return response.body
		end

	end

	def make_get_request(uri_path)
		get_api_access if @twitter_api.nil? #token timeout?

		response = @twitter_api.get(uri_path, HEADERS)
		
		if response.code.to_i >= 300
			puts "GET ERROR occurred with #{uri_path}: "
			puts "Error: #{response}"
		end

		if response.body.nil? #Some successful API calls have nil response bodies, but have 2## response codes.
			return response.code #Examples include 'set subscription', 'get subscription', and 'delete subscription'
		else
			return response.body
		end
	end

	def make_delete_request(uri_path)
		get_api_access if @twitter_api.nil? #token timeout?

		response = @twitter_api.delete(uri_path, HEADERS)

		if response.code.to_i >= 300
			puts "DELETE ERROR occurred with #{uri_path}: "
			puts "Error: #{response}"
		end

		if response.body.nil? #Some successful API calls have nil response bodies, but have 2## response codes.
			return response.code #Examples include 'set subscription', 'get subscription', and 'delete subscription'
		else
			return response.body
		end
	end

	def make_put_request(uri_path)

		get_api_access if @twitter_api.nil? #token timeout?

		response = @twitter_api.put(uri_path, '', {"content-type" => "application/json"})

		if response.code.to_i == 429
			puts "#{response.message}  - Rate limited..."
		end

		if response.code.to_i >= 300
			puts "PUT ERROR occurred with #{uri_path}, request: #{request} "
			puts "Error: #{response}"
		end

		if response.body.nil? #Some successful API calls have nil response bodies, but have 2## response codes.
			return response.code #Examples include 'set subscription', 'get subscription', and 'delete subscription'
		else
			return response.body
		end

	end

end