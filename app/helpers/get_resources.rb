#Attempting to abstract away all the 'resource' metadata and management into this class.
#This class knows where things are stored (on Heroku at least)
#Could have 'dev helper' features for working on different platforms (heroku, local linux, ?).
#Sets up all object variables needed by Bot. One Stop Shop.

#Key feature design details: 

# This bot builds Twitter Quick Reply (menu) lists from a set of local data files. These files are served from the webhook listener server... 
# Bot supports: 
#     * Single list of locations (up to 20) 
#           * Snowbot uses snow resort locations, @FloodSocial uses Texas cities. 
#     * Look-up for a single list of curated links.
#           * Snowbot presents a short of list of suggested 'learn more' URLs.
#     * Serves photos hosted in single directory of JPEGs.
#           * Snowbot displays random snow photos.
#     * Single list of playlist URLs. Geo-tagged music, why not?


class GetResources
	require 'csv'

	attr_accessor :photos_home,
	              :photos_list,     #CSV with file name and caption. That's it.
	              
	              :locations_home,
	              :locations_list, #This class knows the configurable location list.
	              
	              :links_home,
	              :links_list,
	              
	              :playlists_home,
	              :playlists_list
	
	def initialize()

		#Load resources, populating attributes.
		@photos_home = 'app/config/data/photos' #On Heroku at least.
		if not File.directory?(@photos_home)
			@photos_home = '../config/data/photos'
		end
		@photos_list = []
		@photos_list = get_photos

		@links_home = 'app/config/data/links' #On Heroku at least.
		if not File.directory?(@links_home)
			@links_home = '../config/data/links'
		end
		@links_list = []
		@links_list = get_links

		@locations_home = 'app/config/data/locations' #On Heroku at least.
		if not File.directory?(@locations_home)
			@locations_home = '../config/data/locations'
		end
		@locations_list = []
		@locations_list = get_locations
		
		@playlists_home = 'app/config/data/music' #On Heroku at least.
		if not File.directory?(@playlists_home)
			@playlists_home = '../config/data/music'
		end
		@playlists_list = []
		@playlists_list = get_playlists
	end

	#Take resource file with '#' comment lines and filter them out.
	#Filter out '#' comment lines.
	def filter_list(lines)
		list = []
		
		lines.each do |line|
			if line[0][0] != '#'
				#drop dynamically from array
				list << line
			end
		end
		list
	end

	#photo_list = [] #Load array of photo metadata.
	def get_photos
		list = []
		
		begin
			list = filter_list(CSV.read("#{@photos_home}/photos.csv", {:col_sep => ";"}))
			puts "Have a list of #{photo_list.count} photos..."
		rescue
		end
		
		list
	end

	#list = [] #Load array of curated links.
	def get_links
		list = []
		
		begin
			list = filter_list(CSV.read("#{@links_home}/links.csv", {:col_sep => ";"}))
			puts "Have a list of #{list.count} links..."
		rescue
		end
		
		list
	end

	#list = [] #Load array of curated locations.
	def get_locations
		list = []
		
		begin
			list = filter_list(CSV.read("#{@locations_home}/placesOfInterest.csv"))
		rescue
		end	

		puts "Have a list of #{list.count} locations..."
		list
	end

	#list = [] #Load array of curated locations.
	def get_playlists
		list = []
		
		begin
			list = filter_list(CSV.read("#{@playlists_home}/playlists.csv"))
			puts "Have a list of #{list.count} playlists..."
		rescue
		end
		
		list
	end

  #=======================
	if __FILE__ == $0 #This script code is executed when running this file.
		retriever = GetResources.new
		
		#Example code for loading location file --------
		retriever.locations_home = '/Users/jmoffitt/work/snowbotdev/data/locations'
		locations = retriever.get_locations
		
		locations.each do |resorts|  #explore that list
			puts resorts
		end
	end
end
