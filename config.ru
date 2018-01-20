require 'sinatra'

require_relative 'app'

enable :logging

$stdout.sync = true

run RolltraxRouter
