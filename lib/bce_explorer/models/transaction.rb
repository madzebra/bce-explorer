module BceExplorer
  # Transactions info db storage
  class Transaction
    def initialize(dbh)
      @tx_list = dbh['tx_list']
    end

    # add transaction
    def <<(tx)
      new_tx = { _id: tx['txid'], tx: tx }
      @tx_list.insert(new_tx) if @tx_list.find_one(_id: tx['txid']).nil?
    end

    # get transaction
    def [](txid)
      result = @tx_list.find_one(_id: txid)
      result.nil? ? nil : result['tx']
    end
  end
end
