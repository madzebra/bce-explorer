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
      load_cache_config
    end

    def client
      BceClient::Client.new client_options
    end

    def db
      DB.new db_options
    end

    def cache
      Cache.new cache_options, db_options[:dbname]
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
        dbname: "#{@_db_conf['db_prefix']}_#{@info['Name'].downcase}"
      }
    end

    def cache_options
    	{
    		host: @_cache_conf['host'] || 'localhost',
    		port: @_cache_conf['port'] || 6_379,
    	}
    end

		def load_db_config
			@_db_conf = YAML.load_file "#{Env.root}/config/mongo.yml"
		end

		def load_cache_config
			@_cache_conf = YAML.load_file "#{Env.root}/config/redis.yml"
		end
  end
end
