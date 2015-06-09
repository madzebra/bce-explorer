module BceExplorer
  # Info blocks db storage
  class Info
    def initialize(dbh)
      @info = dbh['info']
    end

    def blocks
      result = @info.find_one(_id: 'blockcount')
      result.nil? ? 0 : result['count']
    end

    def blocks=(count)
      new_count = { _id: 'blockcount', count: count }
      @info.update({ _id: 'blockcount' }, new_count, upsert: true)
    end
  end
end
