module BceExplorer
  # address <==> txid cache storage
  class TxAddress < Base
    def initialize(dbh)
      super dbh
    end

    def <<(info)
      return unless info.keys == [:address, :txid, :type]
      query = info.reject { |k, _| k == :type }
      upsert query, info
    end

    def count(address)
      super address: address
    end

    # get txid list by address
    def [](address)
      query = { address: address }
      order = { _id: :desc }
      find_order_limit(query, order, 50)
        .map { |tx| [tx['txid'], tx['type']] }.to_h
    end
  end
end
