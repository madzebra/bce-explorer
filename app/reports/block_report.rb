module BceExplorer
  # block info report
  class BlockReport
    def initialize(db)
      @block = db.block
    end

    def call(blk)
      res = @block[blk]
      res.tx.map! { |tx| Entities::Transaction.create_from tx } unless res.nil?
    end
  end
end
