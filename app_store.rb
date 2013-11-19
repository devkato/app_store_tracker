
require 'open-uri'
require 'yaml'
require 'cgi'
require 'awesome_print'
require 'yajl'
require 'json'
require 'fileutils'
require 'logger'

# artistId
# genreNames
# artistUrl
# name
# url
class App

  def initialize(data)
  end
end

class AppStore

  def initialize
    @config = Yajl::Parser.parse(YAML.load_file("./config.yml").to_json, symbolize_keys: true)
  end

  def front(device)
    # url = "https://itunes.apple.com/WebObjects/MZStore.woa/wa/storeFront"
    url = "https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewGrouping?cc=us&id=25204&mt=8"
    json = Yajl::Parser.parse(open(url, { "User-Agent" => @config[:user_agent][device] }).read, symbolize_keys: true)

    return json
  end

  def ranking(device, category_name)
    options = {
      cc: 'jp',
      l:  'ja',
      genreId: @config[:ranking][category_name],
    }

    if category_name == :kids
      options[:ageBandId] = 0
    end

    base_url = 'https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewTop?'
    url = base_url + options.map{|k, v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&')

    json = Yajl::Parser.parse(open(url, { "User-Agent" => @config[:user_agent][device] }).read, symbolize_keys: true)

    return json

    # ranking_paid = []
    # ranking_free = []
    # ranking_grossing = []

    # app_info = json[:storePlatformData][:"lockup-charts"][:results]

    # json[:charts].each do |chart|

    #   app_ids = chart[:contentIds]
    #   case chart[:chartId].to_i
    #   when 30 # paid
    #     app_ids.each do |app_id|
    #       ranking_paid << app_info[app_id.to_s.to_sym]
    #     end
    #   when 27 # free
    #     app_ids.each do |app_id|
    #       ranking_free << app_info[app_id.to_s.to_sym]
    #     end
    #   when 38 # grossing
    #     app_ids.each do |app_id|
    #       ranking_grossing << app_info[app_id.to_s.to_sym]
    #     end
    #   end
    # end

    # return {
    #   paid:      ranking_paid,
    #   free:      ranking_free,
    #   grossing:  ranking_grossing,
    # }
  end

  def app(device, url)
    return Yajl::Parser.parse(open(url, { "User-Agent" => @config[:user_agent][device] }).read, symbolize_keys: true)
  end
end

app_store = AppStore.new
logger = Logger::new(STDOUT)
now = Time.now

dir_path = "./dest/#{now.strftime('%Y%m%d')}/#{now.strftime('%H')}"

FileUtils.mkdir_p(dir_path) unless File.exists?(dir_path)

@config = Yajl::Parser.parse(YAML.load_file("./config.yml").to_json, symbolize_keys: true)

[ :iphone, :ipad ].each do |device|

  # store front
  open("#{dir_path}/store_front.#{device}.#{now.strftime('%Y%m%d%H')}.json", 'w').write app_store.front(:iphone)

  # by genre
  @config[:ranking].each do |genre_name, genre_id|
    file_path = "#{dir_path}/#{genre_name}.#{device}.json"

    logger.debug "genre_name: #{genre_name}\tgenre_id: #{genre_id}\tdevice: #{device}\tto #{file_path}"

    open(file_path, 'w').write app_store.ranking(device, genre_name.to_sym)
  end
end

# ap app_store.app(:iphone, "https://itunes.apple.com/jp/app/o-tsu!pai-xie-zhen/id717568128?mt=8")
