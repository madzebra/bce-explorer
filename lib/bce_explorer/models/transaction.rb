module BceExplorer
  # Transactions info db storage
  class Transaction
    def initialize(dbh)
      @tx_list = dbh['tx_list']
    end

    # add transaction
    def <<(tx)
      info = { txid: tx['txid'], tx: tx }
      @tx_list.insert(info) if @tx_list.find_one(txid: tx['txid']).nil?
    end

    # get transaction
    def [](txid)
      result = @tx_list.find_one(txid: txid)
      result.nil? ? nil : result['tx']
    end
  end
end
