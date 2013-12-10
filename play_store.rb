
# require 'android_market_api'
require 'market_bot'

require 'awesome_print'

# lb = MarketBot::Android::Leaderboard.new(:topselling_free, :game)
# lb.update
# # Overall Position 15 Free Apps
# app = AndroidMarket.get_overall_top_selling_free_app(15)
# 
# ap app

lb = MarketBot::Android::Leaderboard.new(:topselling_free, :game)
lb.update

ap lb.results

first_app = MarketBot::Android::App.new(lb.results.first[:market_id])
last_app = MarketBot::Android::App.new(lb.results.last[:market_id])

first_app.update
last_app.update

puts "First place app (#{first_app.title}) price: #{first_app.price}"
puts "Last place app (#{last_app.title}) price: #{last_app.price}"

