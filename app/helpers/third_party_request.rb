require 'json'
require 'open-uri'

class ThirdPartyRequest

	HEADERS = {"content-type" => "application/json"} #Suggested set? Any?

	attr_accessor :keys,
	              :base_url, #Default: 'https://api.twitter.com/'
	              :uri_path #No default.

	def initialize(config_file = nil)

		puts "Creating ThirdPartyAPI object."
		
		#@base_url = 'https://GetSnow.com/'
		#@uri_path = ''
		
		#Get Twitter App keys and tokens. Pull from the 
		#'Config Variables' via the ENV{} hash.
		@keys = {}
	
		@keys['weather_consumer_key'] = ENV['WEATHERUNDERGROUND_KEY']
		@keys['snocountry_consumer_key'] = ENV['SNOCOUNTRY_KEY']
		#@keys['spotify_consumer_key'] = ENV['SPOTIFY_CONSUMER_KEY'] #Not used yet.

	end

	#http://feeds.snocountry.net/conditions.php?apiKey=KEY_ID&resortType=Alpine&action=top20
	def get_top_snow_resorts

		open("http://feeds.snocountry.net/conditions.php?apiKey=#{@keys['snocountry_consumer_key']}&resortType=Alpine&action=top20") do |f|
			json_string = f.read
			
			puts json_string
			
			parsed_json = JSON.parse(json_string)
			
			puts parsed_json
			
			
			return "Made call..."
			
		end	
		
		
	end
	
	
  #http://feeds.snocountry.net/conditions.php?apiKey=KEY_ID&ids=303001
	def get_resort_info(resort_id)

		open("http://feeds.snocountry.net/conditions.php?apiKey=#{@keys['snocountry_consumer_key']}&ids=#{resort_id}") do |f|
			json_string = f.read
			puts json_string
			parsed_json = JSON.parse(json_string)
			
			#if parsed_json['openDownHillLifts'] && parsed_json['openDownHillTrails']
			#	return "Ski area is not open."
			#end
			
			resort_data = parsed_json["items"][0]

			#"operatingStatus" --> "Open for Events\/Activities", ""
			
			name = resort_data["resortName"]
			last_snow_date = resort_data["lastSnowFallDate"]
			last_snow_amount = resort_data["lastSnowFallAmount"]
			prev_snow_date = resort_data["prevSnowFallDate"]
			prev_snow_amount = resort_data["prevSnowFallAmount"]
			open_lifts = resort_data["openDownHillLifts"]
			total_lifts = resort_data["maxOpenDownHillLifts"]
			open_trails = resort_data["openDownHillTrails"]
			total_trails = resort_data["maxOpenDownHillTrails"]
			open_acres = resort_data["openDownHillAcres"]
			total_acres = resort_data["maxOpenDownHillAcres"]
			web_site_link = resort_data["webSiteLink"]
			trail_map = resort_data["lgTrailMapURL"]

			resort_summary = "#{name} report:\n" +
				"* Last snow: #{last_snow_amount} inches on #{last_snow_date}\n" +
			  "* Previous snow: #{prev_snow_amount} inches on #{prev_snow_date}\n" +
			  "* Open lifts: #{open_lifts} / #{total_lifts}\n" +
				"* Open trails: #{open_trails} / #{total_trails}\n" +
				"* Open acres: #{open_acres} / #{total_acres}\n" +
				"* Web site: #{web_site_link}\n" +
				"* Trail map: #{trail_map}\n" 
			
			
			return resort_summary

		end



		resort_summary = '(Not implemented yet... by this fall? Trying to find a free snow report API)'
		return "#{resort} information: \n #{resort_summary}"
	end

	def get_current_weather(lat,long)


		#http://api.wunderground.com/api/APIKEY/forecast/astronomy/conditions/q/42.077201843262,-8.4819002151489.json

		open("http://api.wunderground.com/api/#{@keys['weather_consumer_key']}/geolookup/conditions/q/#{lat},#{long}.json") do |f|
			json_string = f.read
			parsed_json = JSON.parse(json_string)
			
			
			
			
			if parsed_json['response'] && parsed_json['response']['error']
				return "No weather report available for that location"
			end

			#Generate place name
			city = parsed_json['location']['city']
			state = parsed_json['location']['state']
			country = parsed_json['location']['country_name']
			place_name = "#{city}, #{state}, #{country}" 

			#Generate weather summary
			weather = parsed_json['current_observation']['weather']
			temp = parsed_json['current_observation']['temperature_string']
			feels_like = parsed_json['current_observation']['feelslike_string']
			wind = parsed_json['current_observation']['wind_string']
			rain_today = parsed_json['current_observation']['precip_today_string']
			forecast_url = parsed_json['current_observation']['forecast_url']

			weather_summary = "* #{weather}\n" +
			                  "* Current temp: #{temp}\n" +
				                "* Feels like: #{feels_like}  \n" +
			                  "* Wind speed: #{wind}  \n" +
			                  "* Rain today: #{rain_today}  \n" +
			                  "--> #{forecast_url}\n"

			return "Current weather conditions in #{place_name}: \n #{weather_summary}"
		end
		
	end

end

if __FILE__ == $0 #This script code is executed when running this file.

	thirdPartyAPI = ThirdPartyRequest.new

	#Testing WeatherUnderground
	#response = thirdPartyAPI.get_current_weather(5,-15)
	#puts response
	#response = thirdPartyAPI.get_current_weather(40.0150,-105.2705)
	#puts response
	#response = thirdPartyAPI.get_current_weather(42.3357,-95.3475)
	#puts response
	
	
	#response = thirdPartyAPI.get_top_snow_resorts
	#Given Resort name, look up resort ID
	resort_id = 303001 #A-Basin
	#resort_id = 615013 #The Remarkables

	response = thirdPartyAPI.get_resort_info(resort_id)
	puts response

end