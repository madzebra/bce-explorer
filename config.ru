require 'rubygems'
require 'bundler/setup'

root = File.expand_path '.', File.dirname(__FILE__)

require "#{root}/engine"

engine = BceExplorer::Engine.new(root)
engine.coins.each do |name, coin|
  map "/#{name}" do
    run engine.explorer_app(coin)
  end
end

run engine.frontend_app
