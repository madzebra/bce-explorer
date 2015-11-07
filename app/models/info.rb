module BceExplorer
  # info blocks db storage
  class Info < Base
    def initialize(dbh)
      super dbh
    end

    def blocks
      result = find 'blockcount'
      result.nil? ? 0 : result['count']
    end

    def blocks=(count)
      query = { _id: 'blockcount' }
      update = { '$set' => { count: count } }
      upsert query, update
    end

    def money_supply
      supply = network['moneysupply']
      supply.nil? ? (10**10).to_f : supply
    end

    def network
      result = find 'network_info'
      result.nil? ? {} : result['info']
    end

    def network=(info)
      query = { _id: 'network_info' }
      update = { '$set' => { info: info } }
      upsert query, update
    end

    def peers
      result = find 'peers_info'
      result.nil? ? [] : result['info']
    end

    def peers=(info)
      query = { _id: 'peers_info' }
      update = { '$set' => { info: info } }
      upsert query, update
    end
  end
end
