module BceExplorer
  # Guesstimated Wallet Storage
  #
  # ... uses address db storage
  # _id - address
  # wallet - wallet id
  class Wallet < Base
    def initialize(dbh)
      super dbh, 'address'
    end

    # merge addresses with wallets
    def merge!(addresses)
      return if addresses.empty? # nothing to do here

      update = { '$set' => { wallet: id(addresses) } }
      if addresses.is_a? Array
        addresses.each { |address| upsert({ _id: address }, update) }
      else
        upsert({ _id: addresses }, update)
      end
    end

    # fetches wallet info
    # returns top addresses with non-zero balance
    def fetch(wallet)
      query = { wallet: wallet, balance: { '$gt' => 1e-8 } }
      order = { balance: :desc }
      result = find_order_limit query, order, 50
      addresses = result.map { |doc| Entities::Address.create_from(doc) }
      params = { 'id' => wallet, 'name' => name(wallet), 'balance' => balance,
                 'size' => count(wallet), 'addresses' => addresses }
      Entities::Wallet.create_from params
    end

    # size of the wallet
    def count(wallet)
      super wallet: wallet
    end

    # returns the largest wallets
    def top(count = 20)
      aggregate([
        { '$group' => { _id: '$wallet', total: { '$sum' => '$balance' },
                        count: { '$sum' => 1 } } },
        { '$sort' => { total: -1 } },
        { '$limit' => count }
      ]).map do |doc|
        params = { 'id' => doc['_id'], 'name' => name(doc['_id']),
                   'balance' => doc['total'], 'size' => doc['count'] }
        Entities::Wallet.create_from params
      end
    end

    def id(address)
      query = address.is_a?(Array) ? { '$in' => address } : address
      doc = find query
      return new_id if doc.nil?
      return new_id if doc['wallet'].nil?
      doc['wallet']
    end

    def name(wallet)
      query = { wallet: wallet }
      order = { balance: :desc }
      find_order_limit(query, order, 1).map { |a| a['_id'] }.first || wallet
    end

    def balance(wallet)
      balance = 0.0
      aggregate([
        { '$match' => { wallet: wallet } },
        { '$group' => { _id: '$wallet', total: { '$sum' => '$balance' } } },
        { '$limit' => 1 }
      ]).map { |doc| balance += doc['total'] }
      balance
    end

    def exists?(wallet)
      find_all(wallet: wallet).count > 0
    end

    private

    def new_id
      SecureRandom.hex(8)
    end
  end
end
