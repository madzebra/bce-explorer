module BceExplorer
  # Info blocks db storage
  class Info
    def initialize(dbh)
      @info = dbh['info']
    end

    def blocks
      result = @info.find_one(_id: 'blockcount')
      result.nil? ? 0 : result['count'].to_i
    end

    def blocks=(count)
      @info.update({ _id: 'blockcount' }, { count: count }, { upsert: true })
    end
  end
end
