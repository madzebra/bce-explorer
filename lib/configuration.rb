require 'yaml'

module BceExplorer
  # Coin configuration class
  class Configuration
    attr_reader :info

    FRONTEND_KEYS = %w(Name Tag Algorithm
                       BitcoinTalk GitHub Website Twitter PaperWallet)

    def initialize(coin_config_file)
      coin_config = YAML.load_file coin_config_file
      @info = coin_config.select { |k, _| FRONTEND_KEYS.include? k }
      @rpc =  coin_config.select { |k, _| k[0, 5] == '_rpc_' }
      load_db_config
    end

    def client
      BceClient::Client.new client_options
    end

    def db
      DB.new db_options
    end

    private

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
        host: @_db_conf['host'] || 'localhost',
        port: @_db_conf['port'] || 27_017,
        dbname: "#{@_db_conf['db_prefix']}_#{@info['Name'].downcase}" || 'bce'
      }
    end

    def load_db_config
      @_db_conf = YAML.load_file Env.mongo_conf_file
    end
  end
end
