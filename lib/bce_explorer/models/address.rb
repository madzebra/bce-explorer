module BceExplorer
  # Address balance storage
  class Address
    def initialize(dbh)
      @addr = dbh['addresses']
      @addr_tx = dbh['address_tx']
      @tx = Transaction.new dbh
    end

    # get balance
    def [](address)
      result = @addr.find_one(address: address)
      result.nil? ? 0.0 : result['balance']
    end

    # set balance
    def []=(address, balance)
      result = @addr.find_one(address: address)
      if result.nil?
        @addr.insert(address: address, balance: balance)
      else
        @addr.update({ _id: result['_id'] }, '$set' => { balance: balance })
      end
      balance
    end

    def add_tx(info)
      return unless info.keys == [:address, :txid]
      @addr_tx.insert(info) if @addr_tx.find_one(info).nil?
    end

    def info(address)
      balance, tx_count, tx = 0.0, 0, nil
      unless nonexisting_address? address
        balance = self[address]
        tx_count = @addr_tx.find(address: address).count
        tx = find_tx(address).map { |txid| @tx[txid] }.reject(&:nil?)
      end
      { 'address' => address, 'balance' => balance,
        'tx_count' => tx_count, 'tx' => tx }
    end

    def top(count)
      @addr.find.sort(balance: :desc).limit(count)
    end

    private

    def find_tx(address)
      tx = @addr_tx.find(address: address).sort(_id: :desc).limit(20)
      tx.nil? ? [] : tx.map { |row| row['txid'] }
    end

    def nonexisting_address?(address)
      @addr.find_one(address: address).nil?
    end
  end
end
