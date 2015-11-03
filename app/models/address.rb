module BceExplorer
  # Address balance storage
  class Address < Base
    def initialize(dbh)
      super dbh
    end

    # get address balance
    def [](address)
      result = find address
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

    def exists?(address)
      !find(address).nil?
    end
  end
end
