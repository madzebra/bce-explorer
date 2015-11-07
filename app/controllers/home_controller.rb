module BceExplorer
  # Home controller contains coin list
  class HomeController < ApplicationController
    set :layout_name, :home_layout

    def initialize(coins)
      @coins = coins
      super
    end

    get '/' do
      render_with :home
    end

    get '*' do
      not_found
    end
  end
end
