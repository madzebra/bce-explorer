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

    def add(address, value)
      self[address] += value
      do_update 'received', address, value
    end

    def sub(address, value)
      self[address] -= value
      do_update 'sent', address, value
    end

    def minted(address, value)
      do_update 'minted', address, value
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
      change = { '$set' => { balance: balance } }
      upsert query, change
    end

    def fetch(address)
      doc = find address
      doc.nil? ? nil : Entities::Address.create_from(doc)
    end

    def exists?(address)
      !find(address).nil?
    end

    private

    def do_update(param, address, value)
      doc = find address
      return if doc.nil?
      new_mint = (doc[param] || 0.0) + value
      query = { _id: address }
      change = { '$set' => { param => new_mint } }
      update query, change
    end
  end
end
