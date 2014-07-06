require "rubygems"
require "bundler/setup"
require "active_record"
require 'yaml'

project_root = File.dirname(File.absolute_path(__FILE__))
Dir.glob(project_root + "/models/*.rb").each { |f| require f }
connection_details = YAML::load(File.open(project_root+'/config/database.yml'))
ActiveRecord::Base.establish_connection(connection_details)