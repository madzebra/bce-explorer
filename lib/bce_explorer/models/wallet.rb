module BceExplorer
  # guesstimated wallet storage
  class Wallet < Base
    def initialize(dbh)
      super dbh, 'address'
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

    # the largest wallets
    def top(count = 20)
      aggregate([
        { '$group' => { _id: '$wallet', total: { '$sum' => '$balance' } } },
        { '$sort' => { total: -1 } },
        { '$limit' => count }
      ])
    end

    def id(address)
      query = address.is_a?(Array) ? { '$in' => address } : address
      result = find_one query
      return new_id if result.nil?
      return new_id if result['wallet'].nil?
      result['wallet']
    end

    def name(wallet)
      query = { wallet: wallet }
      order = { balance: :desc }
      find_order_limit(query, order, 1).map { |a| a['_id'] }.first || wallet
    end

    private

    def new_id
      SecureRandom.hex(8)
    end
  end
end
