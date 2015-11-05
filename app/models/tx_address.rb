module BceExplorer
  # address <==> txid cache storage
  class TxAddress < Base
    def initialize(dbh)
      super dbh
    end

    def <<(info)
      return unless info.keys == [:address, :txid, :type]
      upsert info, info
    end

    def count(address)
      super address: address
    end

    # get txid list by address
    def [](address)
      query = { address: address }
      order = { _id: :desc }
      limit = 50
      result = {}
      find_order_limit(query, order, limit).each do |tx|
        result[tx['txid']] = tx['type']
      end
      result
    end
  end
end
