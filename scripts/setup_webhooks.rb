#Code for configuring webhook details for the Account Activity API.
#Note that this code currently does not have support for running on Heroku. To add that the configuration details
#(OAuth keys) should be loaded from the ENV[] structure.

require 'json'
require 'cgi'
require 'optparse'

require_relative '../app/helpers/api_oauth_request'

class TaskManager

	attr_accessor :twitter_api,
                :api_tier,  #Introduction of Premium AA API, neccessitates new config metadata.
                :env_name,
	              :webhook_configs,  #An array of Webhook IDs. Currently numeric(e.g. 88888888888888), subject to change?
								:uri_path #This gets built, depending on the API tier, and is passed to the api_oauth_request manager.
	
	def initialize(config=nil)

    @uri_path = "/1.1/account_activity"

    #Create a 'wrapper' to the the Twitter Account Activity API, and get authenticated.
		@twitter_api = ApiOauthRequest.new(config)
		#OAuth keys are loaded from ENV by ApiOAuthRequest object, unless a config file is specified.
		#@keys['consumer_key'] = ENV['CONSUMER_KEY']
		#@keys['consumer_secret'] = ENV['CONSUMER_SECRET']
		#@keys['access_token'] = ENV['ACCESS_TOKEN']
		#@keys['access_token_secret'] = ENV['ACCESS_TOKEN_SECRET']

		@twitter_api.get_api_access
		
		@webhook_configs = []
		
  end

	def get_webhook_configs
		puts "Retrieving webhook configurations..."

		@twitter_api.get_api_access

		if @api_tier == 'premium'
			@uri_path = "#{@uri_path}/all/#{@env_name}/webhooks.json"
		else
			@uri_path = "#{@uri_path}/webhooks.json"
		end

		response = @twitter_api.make_get_request(@uri_path)

		results = JSON.parse(response)

		if results.count == 0
			puts "No existing configurations... "
		else
			results.each do |result|
				@webhook_configs << result
        #TODO: puts "Webhook ID #{result['id']} --> #{result['url']}"
			end
		end

		@webhook_configs
	end

	def set_webhook_config(url)
		puts "Setting a webhook configuration..."

		if @api_tier == 'premium'
			@uri_path = "#{@uri_path}/all/#{@env_name}/webhooks.json?url=#{url}"
		else
			@uri_path = "#{@uri_path}/webhooks.json?url=#{url}"
		end

		response = @twitter_api.make_post_request(@uri_path,nil)
		results = JSON.parse(response)
		
		if results['errors'].nil?
			puts "Created webhook instance with webhook_id: #{results['id']} | pointing to #{results['url']}"
		else
			puts results['errors']
		end

		results
	end

	# id: webhook_id (enterprise), :env_name (premium)
	def delete_webhook_config(id, name=nil)
		puts "Attempting to delete configuration for webhook id: #{id}."

		if @api_tier == 'premium'
			@uri_path = "#{@uri_path}/all/#{name}/webhooks/#{id}.json"
		else
			@uri_path = "#{@uri_path}/webhooks/#{id}.json"
		end

		response = @twitter_api.make_delete_request(@uri_path)

		if response == '204'
			puts "Webhook configuration for #{id} was successfully deleted."
		else
			puts response
		end

		response
	end

	# id: webhook_id (enterprise), :env_name (premium)
	def get_webhook_subscription(id)
		puts "Retrieving webhook subscriptions..."

		if @api_tier == 'premium'
			@uri_path = "#{@uri_path}/all/#{id}/subscriptions.json"
		else
			@uri_path = "#{@uri_path}/webhooks/#{id}/subscriptions/all.json"
		end

		response = @twitter_api.make_get_request(@uri_path)

		if response == '204'
			puts "Webhook subscription exists for #{id}."
		else
			puts "Webhook subscription does not exist for #{id}."
		end
		
		response
	end

	# Sets a subscription for current User context.
	# # id: webhook_id (enterprise), :env_name (premium)
	def set_webhook_subscription(id)
		puts "Setting subscription for 'host' account for webhook id: #{id}"

		if @api_tier == 'premium'
			@uri_path = "#{@uri_path}/all/#{id}/subscriptions.json"
		else
			@uri_path = "#{@uri_path}/webhooks/#{id}/subscriptions/all.json"
		end

		response = @twitter_api.make_post_request(@uri_path, nil)
		
		if response == '204'
			puts "Webhook subscription for #{id} was successfully added."
		else
			puts response
		end

    response
	end

	# id: webhook_id (enterprise), :env_name (premium)
	def delete_webhook_subscription(id)
		puts "Attempting to delete subscription for webhook: #{id}."

		if @api_tier == 'premium'
			@uri_path = "#{@uri_path}/all/#{id}/subscriptions/all.json"
	  else
			@uri_path =  "#{@uri_path}/webhooks/#{id}/subscriptions.json"
		end

		response = @twitter_api.make_delete_request(@uri_path)

		if response == '204'
			puts "Webhook subscription for #{id} was successfully deleted."
		else
			puts response
		end
		
		response
	end


	def confirm_crc(id)

		if @api_tier == 'premium'
			@uri_path =  "#{@uri_path}/all/#{@env_name}/webhooks/#{id}.json"
		else
		  @uri_path =  "#{@uri_path}/webhooks/#{id}.json"
		end

		response = @twitter_api.make_put_request(uri_path)
		
		puts response
		
		if response == '204'
			puts "CRC request successful and webhook status set to valid."
		else
			puts "Webhook URL does not meet the requirements. Please consult: https://developer.twitter.com/en/docs/accounts-and-users/subscribe-account-activity/guides/securing-webhooks"
		end

		response

	end

end

#=======================================================================================================================

#trigger CRC ('crc'),
#set config ('set'),
#list configs ('list'),
#delete config ('delete'),
#subscribe app ('subscribe'),
#unsubscribe app ('unsubscribe')
#get subscription ('subscription').")

if __FILE__ == $0 #This script code is executed when running this file.

  #Supporting any command-line options? Handle here.
  #options: -config -id -url
	OptionParser.new do |o|

		#Passing in a config file.... Or you can set a bunch of parameters.
		o.on('-c CONFIG', '--config', 'If not setting ENV variableds, you can specify a configuration file (including path) that provides OAuth details. ') { |config| $config = config}
		o.on('-t TASK','--task', "Securing Webhooks Task to perform: trigger CRC ('crc'), set config ('set'), list configs ('list'), delete config ('delete'), subscribe app ('subscribe'), unsubscribe app ('unsubscribe'),get subscription ('subscription').") {|task| $task = task}
		o.on('-u URL','--url', "Webhooks 'consumer' URL, e.g. https://mydomain.com/webhooks/twitter.") {|url| $url = url}
		o.on('-i ID','--id', 'Webhook ID') {|id| $id = id}
    o.on('-n NAME', '--name', 'Premium environment name. Required with the premium tier.'){|name| $name = name}
				
		#Help screen.
		o.on( '-h', '--help', 'Display this screen.' ) do
			puts o
			exit
		end

		o.parse!
	end
	
	if $task.nil? then
		$task = 'list'
  end

  task_manager = TaskManager.new($config)

  #If a name is provided, then we are working with Premium tier. If not, then Enterprise.
	if $name.nil? then
		task_manager.api_tier = 'enterprise'
  else
		task_manager.api_tier = 'premium'
		task_manager.env_name = $name
	end

  if task_manager.api_tier == 'premium' and $task != 'crc'
    $id = task_manager.env_name
  end

	if $task == 'list'
		configs = task_manager.get_webhook_configs
		configs.each do |config|
			puts "Webhook ID #{config['id']} --> #{config['url']}"
		end
  elsif $task == 'set'
    if $url.nil?
			puts "Must provide a URL when establishing a webhook. Quitting. "
      exit
    else
			url = CGI::escape($url)
		end

		task_manager.set_webhook_config(url)
	elsif $task == 'delete'
		task_manager.delete_webhook_config($id)
	elsif $task == 'subscribe'
		task_manager.set_webhook_subscription($id)
	elsif $task == 'unsubscribe'
		task_manager.delete_webhook_subscription($id)
	elsif $task == 'subscription'
		task_manager.get_webhook_subscription($id)
  elsif $task == 'crc' #triggers a CRC for all configured webhook ids unless a specific id is passed in.

		if $id.nil?
      puts "Triggering a CRC requires a webhook ID to be passed. You can run the 'list' task to retrive those."
    else
      result = task_manager.confirm_crc($id)
      puts result
    end

	else
		puts "Unhandled task. Available tasks: 'list', 'crc', 'set', 'subscribe', 'delete'"
	end	
end
