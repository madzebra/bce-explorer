module BceExplorer
  # Engine class creates web applications
  # one sinatra app per coin + app for coin list
  class Engine
    attr_reader :coins

    def self.start(root)
      Env.root = root
      new
    end

    def initialize
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

    def db_index
      @coins.each { |_, coin| coin.db.create_index }
    end

    def db_sync
      @coins.each do |tag, coin|
        puts "Syncing coin #{tag.upcase} ..."
        sync(coin.client, coin.db).sync_db
      end
    end

    private

    def sync(client, db)
      Sync.new blockexplorer: client, database: db
    end
  end
end
