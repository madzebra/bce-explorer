module BceExplorer
  # Richlist model
  class Richlist < Base
    def initialize(dbh)
      super dbh, 'address'
    end

    def top(count)
      query = {}
      order = { balance: :desc }
      find_order_limit(query, order, count)
    end
  end
end
