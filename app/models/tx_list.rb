module BceExplorer
  # Transactions db storage
  class TxList < Base
    def initialize(dbh)
      super dbh
    end

    # add transaction
    def <<(tx)
      query = { _id: tx['txid'] }
      update = { '$set' => { tx: tx } }
      upsert query, update
    end

    # get transaction
    def [](txid)
      result = find txid
      result.nil? ? nil : result['tx']
    end
  end
end
