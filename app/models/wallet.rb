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
    def merge(addresses)
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
      addresses = find_order_limit(query, order, 50)
                  .map { |doc| Entities::Address.create_from(doc) }
      Entities::Wallet.create_from 'id' => wallet, 'name' => name(wallet),
                                   'balance' => balance(wallet),
                                   'size' => count(wallet),
                                   'addresses' => addresses
    end

    # size of the wallet
    def count(wallet)
      super wallet: wallet
    end

    # returns the largest wallets
    def top(count = 50)
      aggregate([
        { '$group' => { _id: '$wallet', total: { '$sum' => '$balance' },
                        count: { '$sum' => 1 } } },
        { '$sort' => { total: -1 } },
        { '$limit' => count }
      ]).map { |doc| Entities::Wallet.create_from wallet_params_from(doc) }
    end

    def id(address)
      query = address.is_a?(Array) ? { '$in' => address } : address
      result = find query
      return new_id unless result
      name = result['wallet']
      return new_id unless name
      name
    end

    def name(wallet)
      query = { wallet: wallet }
      order = { balance: :desc }
      find_order_limit(query, order, 1).map { |a| a['_id'] }.first || wallet
    end

    def balance(wallet)
      aggregate([
        { '$match' => { wallet: wallet } },
        { '$group' => { _id: '$wallet', total: { '$sum' => '$balance' } } },
        { '$limit' => 1 }
      ]).inject(0.0) { |a, e| a + e['total'] }
    end

    def exists?(wallet)
      count(wallet) > 0
    end

    private

    def new_id
      SecureRandom.hex(8)
    end

    def wallet_params_from(doc)
      wallet = doc['_id']
      {
        'id' => wallet,
        'name' => name(wallet),
        'balance' => doc['total'],
        'size' => doc['count']
      }
    end
  end
end
