require 'bundler'
Bundler.require

# get the path of the root of the app
APP_ROOT = File.expand_path("..", __dir__)

# require the controller(s)
Dir.glob(File.join(APP_ROOT, 'app', 'controllers', '*.rb')).each { |file| require file }

# require the helper(s)
Dir.glob(File.join(APP_ROOT, 'app', 'helpers', '*.rb')).each { |file| require file }

# require database configurations
#require File.join(APP_ROOT, 'config', 'database')

# configure TaskManagerApp settings
class Application < Sinatra::Base
	set :method_override, true
	set :root, APP_ROOT
	
	puts "APP_ROOT: #{APP_ROOT}"
	
	#set :views, File.join(APP_ROOT, "app", "views")
	#set :public_folder, File.join(APP_ROOT, "app", "public")
end
