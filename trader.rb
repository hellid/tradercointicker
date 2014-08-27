#!/usr/bin/env ruby

require 'socket'
require 'rubygems'
require 'json'
require 'net/http'

class IRCBot

	def initialize(name, server, port, channel)
		@channel = channel
		@socket = TCPSocket.open(server, port)
		say "USER #{name} 0 * #{name}"
		say "NICK #{name}"
		say "JOIN ##{@channel}"
	end

	def say(msg)
		@socket.puts msg + "\n"
	end

	def say_to_channel(msg)
		say "PRIVMSG ##{@channel} :#{msg}\n"
	end

	def parse_line(line)
		parts = line.split
		if parts.length >= 4
			msg = parts[3..-1].join(" ")[1..-1]
			say_to_channel "woof" if msg.include?("DogeBot")
			if /^(\!price)/ =~ msg
				get_price
			elsif /^\!c\s(\d+)/ =~ msg
				convert_price(Regexp.last_match(1))
			elsif msg == "!info"
				say_to_channel 'I am an IRC bot written in ruby to help with DogeCoin related tasks. PM BradPitt with feature requests.'\
				' I am using data from http://cryptsy.com (for DOGE) and http://vircurex.com (for BTC/USD conversion).'\
				' Source code available at http://github.com/clindsay107/Doge_ticker'
			elsif msg == "!help"
				show_help
			elsif msg == "!tip"
				show_tip_addr
			elsif msg == "!buy"
				show_buy_walls
			elsif msg == "!sell"
				show_sell_walls
			elsif msg == "!price usd"
				usd_price
			end
		end
	end

	#def find_thread
	#	url = "http://a.4cdn.org/g/catalog.json"
	#	thread_url = "http://boards.4chan.org/g/res/"
	#	response = Net::HTTP.get_response(URI(url))
	#	begin
	#		data = JSON.parse(response.read_body)
	#		(0..10).each do |page|
	#			data[page]["threads"].each do |thread|
	#				p thread["sub"]
	#				if !thread["sub"].nil? && thread["sub"].downcase == "general doge thread"
	#					return say_to_channel "Last bumped thread: \x02#{thread_url << thread["no"].to_s}\x02"
	#				end
	#			end
	#		end
	#	rescue JSON::ParserError
	#		say_to_channel "Such error fetching thread, many sorry"
	#	end

	#	say_to_channel "Shibe could not fetch current thread, try making a new one."
	#end

	def get_price
		url = "https://c-cex.com/t/trdr-btc.json"
		response = Net::HTTP.get_response(URI(url))
		begin 
			data = JSON.parse(response.read_body)
			latest_trade = data["ticker"][0]
			#quantity = latest_trade["quantity"].slice(0..(latest_trade["quantity"].index('.')+2))
			price = latest_trade["lastprice"]
			buy = lastest_trade["lastsell"]
			sell = lastest_trade["lastbuy"]
			#time = latest_trade["time"].slice(latest_trade["time"].index(" ")+1..-1)

			say_to_channel "Last price (BTC) : \x02#{price}\x02, Last Buy : \x02#{buy}\x02, Last Sell : \x02#{sell}\x02."
		rescue JSON::ParserError
			say_to_channel "Much error, such 502 Bad Gateway (try again in a minute, Shibe is many sorry)"
			rescue 
			say_to_channel "Many error when fetching TRDR price, such sorry. Contact head shibe for troubleshooting! (API may be changed/down)"
		end

	end
	
	def usd_price
		url = "https://c-cex.com/t/trdr-usd.json"
		response = Net::HTTP.get_response(URI(url))
		begin 
			data = JSON.parse(response.read_body)
			latest_trade = data["ticker"][0]
			#quantity = latest_trade["quantity"].slice(0..(latest_trade["quantity"].index('.')+2))
			price = latest_trade["lastprice"]
			buy = lastest_trade["lastsell"]
			sell = lastest_trade["lastbuy"]
			#time = latest_trade["time"].slice(latest_trade["time"].index(" ")+1..-1)

			say_to_channel "Last price (USD) : \x02#{price}\x02, Last Buy : \x02#{buy}\x02, Last Sell : \x02#{sell}\x02."
		rescue JSON::ParserError
			say_to_channel "Much error, such 502 Bad Gateway (try again in a minute, Shibe is many sorry)"
			rescue 
			say_to_channel "Many error when fetching TRDR price, such sorry. Contact head shibe for troubleshooting! (API may be changed/down)"
		end

	end

	#def convert_price(amount)

		#fetch current BTC price
		#url = "http://api.bitcoinaverage.com/exchanges/USD"
		#response = Net::HTTP.get_response(URI(url))
		#begin
		#	data = JSON.parse(response.read_body)
		#	last_btc_price = data["btce"]["rates"]["last"]
		#rescue
		#	say_to_channel "Many error when fetching BTC price, such sorry. Contact head shibe for troubleshooting! (API may be changed/down)"
		#	return
		#end

		#fetch current DOGE price
		#url = "http://pubapi.cryptsy.com/api.php?method=singlemarketdata&marketid=132"
		#response = Net::HTTP.get_response(URI(url))
		#begin 
		#	data = JSON.parse(response.read_body)
		#	last_doge_price = data["return"]["markets"]["DOGE"]["recenttrades"][0]["price"]
		#rescue JSON::ParserError
		#	say_to_channel "Much error, such 502 Bad Gateway when fetching DOGE price. Contact head shibe for troubleshooting!"
		#	return
		#rescue 
		#	say_to_channel "Many error when fetching DOGE price, such sorry. Contact head shibe for troubleshooting! (API may be changed/down)"
		#end

		#puts ">>>BTC: #{last_btc_price}"
		#puts ">>>DOGE: #{last_doge_price}"

		#amount_usd = (last_btc_price.to_f * last_doge_price.to_f) * amount.to_f
		#say_to_channel "$\x02#{amount_usd.round(2)}\x02 USD"
	#end

	def show_help
		say_to_channel '!price for last price'
		say_to_channel '!buy for last buy price'
		say_to_channel '!sell for last sell price'
		say_to_channel '!info for info about this bot'
		say_to_channel '!tip for showing tip address for developer.'
	end

	def show_tip_addr
		say_to_channel "If you enjoy the utility this bot provides, please send a tip to 18gT2MCzyZYajLDR3ixr69HoEam3S94gyS"
	end

	def show_buy_walls
		url = "https://c-cex.com/t/trdr-btc.json"
		response = Net::HTTP.get_response(URI(url))
		begin 
			data = JSON.parse(response.read_body)
			buy_orders = data["ticker"][0]
			buy = buy_orders["sell"]
			#current_wall_str = ""
			#(0..2).each do |x|
			#	current_wall_str << "\x02BTC " + buy_orders[x]["total"] + "\x02 @ \x02" + buy_orders[x]["price"].slice(buy_orders[x]["price"].index(/[1-9]/)..-1) + "\x02, "
			end

			say_to_channel "Current Buy Price: #{buy}"
		rescue JSON::ParserError
			say_to_channel "Much error, such 502 Bad Gateway (try again in a minute, Shibe is many sorry)"
		end
	end

	def show_sell_walls
		url = "https://c-cex.com/t/trdr-btc.json"
		response = Net::HTTP.get_response(URI(url))
		begin 
			data = JSON.parse(response.read_body)
			sell_orders = data["ticker"][0]
			sell = sell_orders["buy"]
			#current_wall_str = ""
			#(0..2).each do |x|
			#	current_wall_str << "\x02BTC " + sell_orders[x]["total"] + "\x02 @ \x02" + sell_orders[x]["price"].slice(sell_orders[x]["price"].index(/[1-9]/)..-1) + "\x02, "
			end

			say_to_channel "Current Sell Price: #{sell}"
		rescue JSON::ParserError
			say_to_channel "Much error, such 502 Bad Gateway (try again in a minute, Shibe is many sorry)"
		end
	end

	def run
		until @socket.eof? do
			message = @socket.gets
			puts 'SERV << ' + message
			parse_line(message)

			if message.include?("PING")
				say 'PONG :pingis'
			end
		end
	end
end

bot = IRCBot.new('TraderCoinInfo', 'irc.freenode.net', 6667, 'tradercoin')
bot.run
