module BceExplorer
  # block info report
  class BlockReport
    def initialize(db)
      @block = db.block
      @tx = db.tx
    end

    def call(hash_or_index)
      index = hash_or_index.to_i
      blk = (index.to_s == hash_or_index) ? hash_or_index : index
      res = @block[blk]
      res.tx.map! do |tx|
        tx_doc = @tx[tx['txid']]
        Entities::Transaction.create_from(tx_doc) if tx_doc
      end if res
      res
    end
  end
end
