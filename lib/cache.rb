module BceExplorer
  # Cache class
  class Cache
    def initialize(settings, key_prefix)
      @key_prefix = key_prefix
      @redis = Redis.new settings
    end

    def cache_for(key, ttl = 60, &block)
      serialize_fun = -> (inp) { inp }
      deserialize_fun = -> (inp) { inp }
      do_cache key, ttl, serialize_fun, deserialize_fun, block
    end

    def cache_obj_for(key, ttl = 60, &block)
      serialize_fun = -> (inp) { inp.to_json }
      deserialize_fun = -> (inp) { JSON.parse inp }
      do_cache key, ttl, serialize_fun, deserialize_fun, block
    end

    private

    def do_cache(key, ttl, serialize_fun, deserialize_fun, block)
      cache_key = "#{@key_prefix}_#{key}"
      result = @redis.get cache_key
      if result.nil? # cache miss
        result = serialize_fun.call(block.call)
        @redis.set cache_key, result
        @redis.expire cache_key, ttl
      end
      deserialize_fun.call result
    end
  end
end
