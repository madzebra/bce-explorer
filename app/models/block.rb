module BceExplorer
  # Block db storage
  #
  # _id - block index
  # hash - block hash
  # block - block content
  class Block < Base
    def initialize(dbh)
      super dbh
    end

    # add block to db
    def <<(block)
      query = { _id: block['height'] }
      update = { '$set' => { hash: block['hash'], block: block } }
      upsert query, update
    end

    # get block by index or by hash string
    def [](hash_or_index)
      result = case
               when hash_or_index.is_a?(String) then find_by hash: hash_or_index
               when hash_or_index.is_a?(Integer) then find hash_or_index
               end

      Entities::Block.create_from(result['block']) if result
    end

    def valid?(hash_or_index)
      return false if hash_or_index.length > 100
      block_index = hash_or_index.to_i
      if block_index.to_s == hash_or_index
        self[block_index]
      elsif hash_or_index[/\w+/] == hash_or_index
        self[hash_or_index]
      else
        false
      end
    end

    def last(limit = 50)
      query = {}
      order = { _id: :desc }
      find_order_limit(query, order, limit)
        .map { |block| Entities::Block.create_from block['block'] }
    end
  end
end
