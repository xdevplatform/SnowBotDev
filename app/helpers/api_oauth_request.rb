#With many Twitter (Public) APIs, you can just use something like the 'twitter' gem.
#This example instead builds requests making the 'oauth' gem, and is not Twitter specific.

require 'json'
require 'oauth'
require 'yaml'

class ApiOauthRequest

	HEADERS = {"content-type" => "application/json"}

	attr_accessor :keys,
	              :api_request,
	              :base_url, #Default: 'https://api.twitter.com/'
								:uri_path

	def initialize(config=nil)

		#puts "Creating OAuth manager object..."

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

		@api_request = OAuth::AccessToken.from_hash(consumer, token)

  end

  def make_post_request(uri_path, request)
		get_api_access if @api_request.nil? #token timeout?

		#puts "request = #{request}"
		#puts uri_path
		#puts HEADERS

		response = @api_request.post(uri_path, request, HEADERS)

		#puts "response = #{response}"

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
		get_api_access if @api_request.nil? #token timeout?

		response = @api_request.get(uri_path, HEADERS)
		
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
		get_api_access if @api_request.nil? #token timeout?

		response = @api_request.delete(uri_path, HEADERS)

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

		get_api_access if @api_request.nil? #token timeout?

		response = @api_request.put(uri_path, '', {"content-type" => "application/json"})

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