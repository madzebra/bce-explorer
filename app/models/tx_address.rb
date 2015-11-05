module BceExplorer
  # address <==> txid cache storage
  class TxAddress < Base
    def initialize(dbh)
      super dbh
    end

    def <<(info)
      return unless info.keys == [:address, :txid, :type]
      doc = find_by info.reject { |k, _| k == :type }
      unless doc.nil?
        return if doc['type'] == 'self'
        info[:type] = 'self' if doc['type'] != info[:type]
      end
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
      find_order_limit(query, order, limit).map { |tx| tx['txid'] }
    end
  end
end
