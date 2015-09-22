require 'rubygems'
require 'bundler/setup'

Bundler.require

root = File.expand_path '.', File.dirname(__FILE__)

require "#{root}/boot"

engine = BceExplorer::Engine.new(root)
engine.coins.each do |name, coin|
  map "/#{name}" do
    run engine.explorer_controller(coin)
  end
end

run engine.home_controller
