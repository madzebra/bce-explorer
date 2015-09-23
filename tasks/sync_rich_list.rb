root = File.expand_path '..', File.dirname(__FILE__)

require 'rubygems'
require 'bundler/setup'

Bundler.require

require "#{root}/boot"

BceExplorer::Engine.new(root).sync_rich_list
