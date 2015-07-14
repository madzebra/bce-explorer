require 'json'
require 'redis'

module BceExplorer
  # Cache class
  class Cache
    def initialize(db_name)
      @db = db_name
      @client = Redis.new
    end

    def cache_for(key, ttl = 60)
      cache_key = "#{@db}_#{key}"
      result = @client.get cache_key
      if result.nil?
        result = yield
        @client.set cache_key, result
        @client.expire cache_key, ttl
      end
      result
    end

    def cache_obj_for(key, ttl = 60)
      cache_key = "#{@db}_#{key}"
      result = @client.get cache_key
      if result.nil?
        result = yield.to_json
        @client.set cache_key, result
        @client.expire cache_key, ttl
      end
      JSON.parse result
    end
  end
end
