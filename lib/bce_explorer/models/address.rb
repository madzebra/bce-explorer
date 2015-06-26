module BceExplorer
  # Address balance
  # and guess wallet storage
  class Address < Base
    def initialize(dbh)
      super dbh, 'addresses'
      # dependencies below needed in #known_address_info
      @tx_address = TxAddress.new dbh
      @tx_list = TxList.new dbh
      @wallet = Wallet.new dbh
    end

    # get address balance
    def [](address)
      result = find_one address
      balance = result['balance'] unless result.nil?
      # this code for situations when address document exists
      # but has no 'balance' property yet, because wallet upserted it
      balance || 0.0
    end

    # set balance
    def []=(address, balance)
      query = { _id: address }
      update = { '$set' => { balance: balance } }
      upsert query, update
    end

    def top(count)
      query = {}
      order = { balance: :desc }
      find_order_limit(query, order, count)
    end

    def info(address)
      if known_address? address
        known_address_info(address)
      else
        { 'address' => address, 'balance' => 0.0,
          'wallet_id' => '', 'wallet_knowns' => 0,
          'tx_count' => 0, 'tx' => nil }
      end
    end

    private

    def known_address?(address)
      !find_one(address).nil?
    end

    def known_address_info(address)
      balance = self[address]
      wid = @wallet.id address
      wsize = @wallet.count wid
      tx_count = @tx_address.count address
      tx = @tx_address[address].map { |txid| @tx_list[txid] }.compact
      { 'address' => address, 'balance' => balance,
        'wallet_id' => wid, 'wallet_knowns' => wsize,
        'tx_count' => tx_count, 'tx' => tx }
    end
  end
end
