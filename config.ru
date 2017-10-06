require 'bundler'
Bundler.require

#require_relative './app/config/environment.rb'
require File.expand_path('../app/config/environment',  __FILE__)

run SnowBotDevApp
