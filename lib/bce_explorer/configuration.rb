module BceExplorer
  # Coin configuration class
  class Configuration
    attr_reader :info

    FRONTEND_KEYS = %w(Name Tag Algorithm BitcoinTalk GitHub Website Twitter)

    def initialize(coin_config = {})
      @info = coin_config.select { |k, _| FRONTEND_KEYS.include? k }
      @rpc =  coin_config.select { |k, _| k[0, 5] == '_rpc_' }
    end

    def client_options
      {
        host: @rpc['_rpc_host'],
        port: @rpc['_rpc_port'],
        username: @rpc['_rpc_user'],
        password: @rpc['_rpc_pass']
      }
    end

    def db_options
      {
        host: 'localhost',
        port: 27_017,
        dbname: "bce_#{@info['Name'].downcase}"
      }
    end
  end
end
