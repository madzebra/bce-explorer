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
      result = @addr.find_one(_id: address)
      result.nil? ? 0.0 : result['balance']
    end

    # set balance
    def []=(address, balance)
      new_balance = { _id: address, balance: balance }
      @addr.update({ _id: address }, new_balance, upsert: true)
    end

    def add_tx(info)
      return unless info.keys == [:address, :txid]
      @addr_tx.insert(info) if @addr_tx.find_one(info).nil?
    end

    def info(address)
      balance = 0.0
      tx_count = 0
      tx = nil
      unless nonexisting_address? address
        balance = self[address]
        tx_count = @addr_tx.count(address: address)
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
      @addr.find_one(_id: address).nil?
    end
  end
end
