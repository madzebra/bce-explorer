module BceExplorer
  # Info blocks db storage
  class Info
    def initialize(dbh)
      @info = dbh['info']
    end

    def blocks
      result = @info.find_one(type: :proccessed_blocks)
      result.nil? ? 0 : result['blockcount']
    end

    def blocks=(count)
      result = @info.find_one(type: :proccessed_blocks)
      if result.nil?
        @info.insert(blockcount: count, type: :proccessed_blocks)
      else
        @info.update({ _id: result['_id'] }, '$set' => { blockcount: count })
      end
    end
  end
end
