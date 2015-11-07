module BceExplorer
  # Home controller contains coin list
  class HomeController < ApplicationController
    def initialize(coins)
      @coins = coins
      super
    end

    get '/' do
      if pjax?
        haml :home_pjax, layout: false
      else
        haml :home, layout: false
      end
    end

    get '*' do
      not_found
    end
  end
end
