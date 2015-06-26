module BceExplorer
  # guesstimated wallet storage
  class Wallet < Base
    def initialize(dbh)
      super dbh, 'addresses'
    end

    # merge addresses with wallets
    def merge!(addresses)
      update = { '$set' => { wallet: id(addresses) } }

      if addresses.is_a? Array
        addresses.each { |address| upsert({ _id: address }, update) }
      else
        upsert({ _id: addresses }, update)
      end
    end

    # find top addresses with non-zero balance
    def info(wallet)
      addresses = find_all(wallet: wallet).map { |a| a['_id'] }
      query = { _id: { '$in' => addresses }, balance: { '$gt' => 1e-8 } }
      order = { balance: :desc }
      find_order_limit(query, order, 100)
    end

    # size of the wallet
    def count(wallet)
      super query: { wallet: wallet }
    end

    # get the largest wallets
    def top(count = 20)
      aggregate([
        { '$group' => { _id: '$wallet', total: { '$sum' => '$balance' } } },
        { '$sort' => { total: -1 } },
        { '$limit' => count }
      ])
    end

    # wallet id
    def id(address)
      query = address.is_a?(Array) ? { '$in' => address } : address
      address = find_one query
      address.nil? ? SecureRandom.hex(8) : address['wallet']
    end

    # wallet name
    def name(wallet)
      query = { wallet: wallet }
      order = { balance: :desc }
      find_order_limit(query, order, 1).map { |a| a['_id'] }.first || wallet
    end
  end
end
