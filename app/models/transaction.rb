module BceExplorer
  # Transactions db Storage
  #
  # _id - mongo id for sorting
  # txid - txid
  # tx - content of tx
  class Transaction < Base
    def initialize(dbh)
      super dbh
    end

    # add transaction
    def <<(tx)
      query = { txid: tx['txid'] }
      update = { '$set' => { tx: tx } }
      upsert query, update
    end

    # get transaction
    def [](txid)
      result = find_by txid: txid
      Entities::Transaction.create_from(result['tx']) if result
    end

    # fetch list of txs
    def fetch(txs = {})
      find_all(txid: { '$in' => txs.keys }).sort(_id: -1)
        .map do |doc|
          tx = doc['tx']
          tx['type'] = txs[tx['txid']]
          Entities::Transaction.create_from tx
        end
    end

    def valid?(txid)
      return false if txid.length > 100
      (txid[/\w+/] == txid) && self[txid]
    end
  end
end
