Dir['./lib/*.rb'].each { |file| require file }
Dir['./app/helpers/*.rb'].each { |file| require file }
require './app/controllers/application_controller.rb'
Dir['./app/controllers/*.rb'].each { |file| require file }
require './app/models/base'
Dir['./app/{models,reports}/*.rb'].each { |file| require file }
