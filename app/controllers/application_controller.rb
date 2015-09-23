module BceExplorer
  # Base Application controller class
  class ApplicationController < Sinatra::Base
    set :public_folder, File.expand_path('public', Env.root)
    set :views, File.expand_path('app/views', Env.root)
    set :haml, format: :html5, ugly: true

    helpers ApplicationHelper
  end
end
