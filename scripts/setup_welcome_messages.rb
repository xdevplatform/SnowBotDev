#Code for managing Default Welcome Messages.
#Note that this code currently does not have support for running on Heroku. To add that the configuration details 
#(OAuth keys) should be loaded from the ENV[] structure.

require 'json'
require 'optparse'

require_relative '../app/helpers/api_oauth_request'
require_relative '../app/helpers/generate_direct_message_content'

class WelcomeMessageManager

	attr_accessor :twitter_api,
	              :message_generator

	def initialize()

		@twitter_api = ApiOauthRequest.new
		@twitter_api.uri_path = '/1.1/direct_messages'
		@twitter_api.get_api_access

		@message_generator = GenerateDirectMessageContent.new(true)

	end

	def create_welcome_message(message)
		puts "Creating Welcome Message..."

		uri_path = "#{@twitter_api.uri_path}/welcome_messages/new.json"

		response = @twitter_api.make_post_request(uri_path, message)
		results = JSON.parse(response)
		
		if not results['errors'].nil?
			puts "Errors occurred."
			errors = []
			errors = results['errors']
			errors.each do |error|
				puts error
			end
			
		else
			results = JSON.parse(response)
		end
	end

	def create_maintenance_message
		welcome_message = @message_generator.generate_system_maintenance_welcome
		welcome_message
	end

	def create_default_welcome_message
		welcome_message = @message_generator.generate_welcome_message_default
		welcome_message
	end


	def set_default_welcome_message(message_id)

		puts "Setting default Welcome Message to message with id #{message_id}..."

		set_rule = {}
		set_rule['welcome_message_rule'] = {}
		set_rule['welcome_message_rule']['welcome_message_id'] = message_id

		uri_path = "#{@twitter_api.uri_path}/welcome_messages/rules/new.json"

		response = @twitter_api.make_post_request(uri_path, set_rule.to_json)
		results = JSON.parse(response)

		rule_id = results['id']
		puts rule_id

	end

	def get_welcome_messages

		puts "Getting welcome message list."

		uri_path = "#{@twitter_api.uri_path}/welcome_messages/list.json"
		response = @twitter_api.make_get_request(uri_path)

		if response == '{}'
			puts "No Welcome Messages created."
			results = nil
		else
			results = JSON.parse(response)
		end

		results

	end

	def delete_welcome_message(id)

		puts "Deleting Welcome Message with id: #{id}."

		uri_path = "#{@twitter_api.uri_path}/welcome_messages/destroy.json?id=#{id}"
		response = @twitter_api.make_delete_request(uri_path)

		if response == '204'
			puts "Deleted message id: #{id} (if it existed)."
		else
			puts "Failed to delete message id: #{id}"
		end
	end

	def delete_all_welcome_messages(messages)

		messages.each do |message|
			delete_welcome_message(message["id"])
		end

	end

# Rules ------------------------------------------------------

	def get_message_rules

		puts "Getting welcome message rules list."

		uri_path = "#{@twitter_api.uri_path}/welcome_messages/rules/list.json"
		response = @twitter_api.make_get_request(uri_path)

		if response == '{}'
			puts "No rules exist."
		else
			results = JSON.parse(response)
			results
		end
	end


	def delete_message_rule(id)

		puts "Deleting rule with id: #{id}."

		uri_path = "#{@twitter_api.uri_path}/welcome_messages/rules/destroy.json?id=#{id}"
		response = @twitter_api.make_delete_request(uri_path)

		results = JSON.parse(response)

		results

	end

end


#=======================================================================================================================
if __FILE__ == $0 #This script code is executed when running this file.

	#Supporting any command-line options? Handle here.
	#options: -config -id -url
	OptionParser.new do |o|

		#Passing in the task at hand. Default Welcome Message management or Welcome Message rule management. 
		o.on('-w WELCOME', '--default', "Default Welcome Management: 'create', 'set', 'get', 'delete'") { |welcome| $welcome = welcome }
		o.on('-r RULE', '--rule', "Welcome Message Rule management: 'create', 'get', 'delete'") { |rule| $rule = rule }
		o.on('-i ID', '--id', 'Message or rule ID') { |id| $id = id }

		#Help screen.
		o.on('-h', '--help', 'Display this screen.') do
			puts o
			exit
		end

		o.parse!
	end

	#welcome message id: 868179877014290436
	#maintenance message id: 868169781060317187
	#rule id: 

	message_manager = WelcomeMessageManager.new
	
	if $welcome == 'create' #Ad hoc, not too often? 
		message_manager.create_welcome_message(message_manager.create_default_welcome_message)
		#message_manager.create_welcome_message(message_manager.create_maintenance_message)

	elsif $welcome == 'set'

		#TODO: Get messages and retrieve ID?
		#response = @twitter_api.make_post_request(uri_path, welcome_message)
		#results = JSON.parse(response)
		#message_id = results['welcome_message']['id']

		message_manager.set_default_welcome_message($id)
	elsif $welcome == 'get'
		welcome_messages = message_manager.get_welcome_messages

		if not welcome_messages.nil?

			messages = welcome_messages["welcome_messages"]

			puts "Message IDs: "

			messages.each do |message|
				puts "Message ID #{message["id"]} with message: #{message["message_data"]["text"]} "
			end

		end

	elsif $welcome == 'delete'
		message_manager.delete_welcome_message($id)

	elsif $welcome == 'delete_all'
		welcome_messages = message_manager.get_welcome_messages

		messages = welcome_messages["welcome_messages"]

		message_manager.delete_all_welcome_messages(messages)

	elsif $rule == 'create'
		message_manager
	elsif $rule == 'get'
		rules = message_manager.get_message_rules

		rules["welcome_message_rules"].each do |rule|
			puts "Rule #{rule["id"]} points to #{rule["welcome_message_id"]}"
		end
		#864475517260636161

	elsif $rule == 'delete'
		message_manager.delete_message_rule($id)
	end

end
