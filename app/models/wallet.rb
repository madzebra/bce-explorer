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
      addresses = find_all(wallet: wallet).map { |a| a['_id'] }
      query = { _id: { '$in' => addresses }, balance: { '$gt' => 1e-8 } }
      order = { balance: :desc }
      find_order_limit(query, order, 100)
        .map { |doc| Entities::Address.create_from doc }
    end

    # size of the wallet
    def count(wallet)
      super wallet: wallet
    end

    # returns the largest wallets
    def top(count = 20)
      aggregate([
        { '$group' => { _id: '$wallet', total: { '$sum' => '$balance' } } },
        { '$sort' => { total: -1 } },
        { '$limit' => count }
      ]).map do |doc|
        wallet_id = doc['_id']
        params = { 'id' => wallet_id, 'name' => name(wallet_id),
                   'balance' => doc['total'], 'size' => count(wallet_id) }
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

    def exists?(wallet)
      find_all(wallet: wallet).count > 0
    end

    private

    def new_id
      SecureRandom.hex(8)
    end
  end
end
