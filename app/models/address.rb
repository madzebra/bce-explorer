module BceExplorer
  # Address db Storage
  #
  # _id - address
  # sent - total sent coins
  # received - total received coins
  # minted - received from coinbase
  # balance - final balance
  class Address < Base
    def initialize(dbh)
      super dbh
    end

    def add(address, value, minted)
      self[address] += value
      do_update 'received', address, value unless minted
    end

    def sub(address, value, minted)
      self[address] -= value
      do_update 'sent', address, value unless minted
    end

    # get address balance
    def [](address)
      result = find address
      balance = result['balance'] if result
      # this code for situations when address document exists
      # but has no 'balance' property yet, because wallet upserted it
      balance || 0.0
    end

    # set balance
    def []=(address, balance)
      query = { _id: address }
      change = { '$set' => { balance: balance } }
      upsert query, change
    end

    def fetch(address)
      result = find address
      Entities::Address.create_from(result) if result
    end

    def exists?(address)
      find(address)
    end

    private

    def do_update(param, address, value)
      result = find address
      return unless result
      new_value = (result[param] || 0.0) + value
      query = { _id: address }
      change = { '$set' => { param => new_value } }
      update query, change
    end
  end
end
