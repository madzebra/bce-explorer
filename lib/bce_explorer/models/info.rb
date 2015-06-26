module BceExplorer
  # info blocks db storage
  class Info < Base
    def initialize(dbh)
      super dbh
    end

    def blocks
      result = find_one 'blockcount'
      result.nil? ? 0 : result['count']
    end

    def blocks=(count)
      query = { _id: 'blockcount' }
      update = { '$set' => { count: count } }
      upsert query, update
    end
  end
end
