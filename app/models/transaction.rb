module BceExplorer
  # Transactions db Storage
  #
  # _id - txid
  # tx - content of tx
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

    # fetch list txs
    def fetch(txs = {})
      find_all(_id: { '$in' => txs.keys })
        .sort('$natural' => -1)
        .map do |doc|
          tx = doc['tx']
          tx['type'] = txs[tx['txid']]
          Entities::Transaction.create_from tx
        end
    end
  end
end
