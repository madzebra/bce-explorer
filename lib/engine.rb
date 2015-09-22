module BceExplorer
  # Engine class creates web applications
  # one sinatra app per coin + app for coin list
  class Engine
    attr_reader :coins

    def initialize(root)
      Env.root = root
      @coins = {}
      Dir["#{Env.coins_path}/*.yml"].each do |coin_config_file|
        config = Configuration.new coin_config_file
        @coins[config.info['Tag'].downcase] = config
      end
    end

    def explorer_controller(coin)
      ExplorerController.new coin
    end

    def home_controller
      HomeController.new @coins
    end

    def sync_rich_list
      @coins.each do |tag, coin|
        puts "Syncing coin #{tag.upcase} ..."
        rich_list(coin.client, coin.db).sync!
      end
    end

    private

    def rich_list(client, db)
      RichList.new blockexplorer: client, database: db
    end
  end
end
