require 'bundler'
Bundler.require

#require File.expand_path('../app/config/environment',  __FILE__)
require File.dirname(__FILE__) + "/app/config/environment"  

run SnowBotDevApp
