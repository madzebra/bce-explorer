module BceExplorer
  # info blocks db storage
  class Info < Base
    def initialize(dbh)
      super dbh
    end

    def blocks
      count = network['blocks']
      count ? count : 0
    end

    def money_supply
      supply = network['moneysupply']
      supply ? supply : (10**10).to_f
    end

    def network
      result = find 'network_info'
      result ? result['info'] : {}
    end

    def network=(info)
      query = { _id: 'network_info' }
      update = { '$set' => { info: info } }
      upsert query, update
    end

    def peers
      result = find 'peers_info'
      result ? result['info'] : []
    end

    def peers=(info)
      query = { _id: 'peers_info' }
      update = { '$set' => { info: info } }
      upsert query, update
    end
  end
end
