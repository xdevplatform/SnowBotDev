require 'bundler'
Bundler.require

require File.expand_path('../app/config/environment',  __FILE__)
#require_relative File.dirname(__FILE__) + "/app/config/environment.rb"  

run SnowBotDevApp
