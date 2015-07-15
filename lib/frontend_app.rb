require 'sinatra/base'
require 'haml'

module BceExplorer
  # Frontend app lists coins on front page
  class FrontendApp < Sinatra::Base
    set :public_folder, File.expand_path('public', Env.root)
    set :views, File.expand_path('views', Env.root)
    set :haml, format: :html5, ugly: true

    def initialize(coins)
      @coins = coins
      super
    end

    get '/' do
      haml :list_coins, layout: false
    end

    get '*' do
      not_found
    end
  end
end
