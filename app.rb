require 'active_record'
require 'rack/csrf'
require 'sinatra'
require 'sinatra/flash'
require 'sqlite3'
require 'thin'
require 'yaml'
require 'active_support/core_ext'

require_relative 'common/union'
require_relative 'models/master'

begin
  $CONFIG = YAML.load_file('config.yml').freeze
  $ROOT = File.dirname(__FILE__)

  def assert_config(field)
    raise "The config file is missing #{field}" unless $CONFIG.has_key?(field)
  end

  assert_config(:connection)
  assert_config(:debug)
  assert_config(:secret)
rescue Exception => e
  puts e
  puts "The config file (config.yml) may be missing certain fields or non-existent"
  exit 1
end

ActiveRecord::Base.establish_connection($CONFIG[:connection])

class LibraryApi < Sinatra::Base
  register Sinatra::Flash

  set :public_folder, $ROOT + '/public'

  configure do
    unless $CONFIG[:debug]
      use Rack::Csrf, :raise => true
    end
    use Rack::Session::Cookie, :secret => $CONFIG[:secret]
  end

  require_relative 'routes/main'
end
