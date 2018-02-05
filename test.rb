require 'active_record'
require 'sqlite3'

require_relative 'models/master'
$CONFIG = YAML.load_file('config.yml').freeze

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection($CONFIG[:connection])

s = Stock.find_by(isbn: 1234)
s.status = 'CHECKED_OUT'
s.save!(false)
