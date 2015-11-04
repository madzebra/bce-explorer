module BceExplorer
  # address <==> txid cache storage
  class TxAddress < Base
    def initialize(dbh)
      super dbh
    end

    def <<(info)
      return unless info.keys == [:address, :txid]
      upsert info, info
    end

    def count(address)
      super address: address
    end

    # get txid list by address
    def [](address)
      query = { address: address }
      order = { _id: :desc }
      limit = 20
      find_order_limit(query, order, limit).map { |tx| tx['txid'] }
    end
  end
end
