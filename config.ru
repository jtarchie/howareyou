require 'dotenv'
Dotenv.load

require_relative 'app'
run Sinatra::Application
