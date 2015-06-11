module BceExplorer
  # Address balance
  # and guess wallet storage
  class Address
    def initialize(dbh)
      @addresses = dbh['addresses']
      @addr_tx = dbh['address_tx']
      @tx = Transaction.new dbh
    end

    # collection: addresses
    # get balance
    def [](address)
      result = find_one address
      balance = result['balance'] unless result.nil?
      balance ||= 0.0 # for situations when address exists w/o balance record
    end

    # set balance
    def []=(address, balance)
      query = { _id: address }
      update = { '$set' => { balance: balance } }
      upsert query, update
    end

    def wallet_merge(addresses)
      update = { '$set' => { wallet: wallet_id(addresses) } }

      if addresses.is_a? Array
        addresses.each { |address| upsert({ _id: address }, update) }
      else
        upsert({ _id: addresses }, update)
      end
    end

    def wallet_info(wallet)
      addresses = @addresses.find wallet: wallet
      return nil if addresses.nil?
      find_top_nz addresses.map { |a| a['_id'] }
    end

    def wallet_name(wallet)
      info = @addresses.find(wallet: wallet).sort(balance: :desc).limit 1
      info.nil? ? wallet : info.map { |wallet| wallet['_id'] }.first
    end

    def wallet_known_count(wallet)
      @addresses.count query: { wallet: wallet }
    end

    def largest_wallets
      @addresses.aggregate([
        { '$group' => { _id: '$wallet', total: { '$sum' => '$balance' } } },
        { '$sort' => { total: -1 } },
        { '$limit' => 20 }
        ])
    end

    def top(count)
      @addresses.find.sort(balance: :desc).limit count
    end

    # collection: address_tx
    def add_tx(info)
      return unless info.keys == [:address, :txid]
      @addr_tx.update info, info, upsert: true
    end

    def info(address)
      info = { 'address' => address, 'balance' => 0.0,
               'wallet_id' => '', 'wallet_knowns' => 0,
               'tx_count' => 0, 'tx' => nil }
      info = known_address_info(address) if known_address? address
      info
    end

    private

    # collection: addresses
    def known_address?(address)
      !find_one(address).nil?
    end

    def known_address_info(address)
      balance = self[address]
      wid = wallet_id address
      wsize = wallet_known_count wid
      tx_count = @addr_tx.count address: address
      tx = find_tx(address).map { |txid| @tx[txid] }.compact
      { 'address' => address, 'balance' => balance,
        'wallet_id' => wid, 'wallet_knowns' => wsize,
        'tx_count' => tx_count, 'tx' => tx }
    end

    def wallet_id(address)
      query = address.is_a?(Array) ? { '$in' => address } : address
      address = find_one query
      address.nil? ? SecureRandom.hex(8) : address['wallet']
    end

    def find_one(address)
      @addresses.find_one _id: address
    end

    # upsert address
    def upsert(query, update)
      @addresses.update query, update, upsert: true
    end

    # find top non-zero address' balances
    def find_top_nz(addresses = [], count = 100)
      query = { _id: { '$in' => addresses }, balance: { '$gt' => 1e-8 } }
      @addresses.find(query).sort(balance: :desc).limit count
    end

    # collection: address_tx
    def find_tx(address)
      tx = @addr_tx.find(address: address).sort(_id: :desc).limit(20)
      tx.nil? ? [] : tx.map { |row| row['txid'] }
    end
  end
end
