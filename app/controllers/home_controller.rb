module BceExplorer
  # Home controller contains coin list
  class HomeController < ApplicationController
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
