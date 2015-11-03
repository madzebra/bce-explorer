module BceExplorer
  # Transactions db storage
  class Transaction < Base
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
      doc = find txid
      doc.nil? ? nil : Entities::Transaction.create_from(doc['tx'])
    end
  end
end
