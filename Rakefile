require 'dotenv/tasks'
require 'sinatra/activerecord/rake'

namespace :db do
  task load_config: [:dotenv] do
    require_relative 'app'
  end
end
