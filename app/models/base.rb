module BceExplorer
  # Base class for db storage
  class Base
    def initialize(dbh, col_name = nil)
      col_name ||= self.class.name.downcase
      # to avoid 'bceexplorer::address' collection name
      col_name = col_name[/[[:word:]]+$/]
      @col = dbh[col_name]
      @cona = col_name
    end

    def count(query)
      @col.count query: query
    end

    private

    # return result or return nil
    def find_one(param)
      @col.find_one _id: param
    end

    def find_all(query)
      @col.find(query)
    end

    def find_order_limit(query, order, limit)
      @col
        .find(query)
        .sort(order)
        .limit(limit)
    end

    # upsert document
    def upsert(query, update)
      @col.update query, update, upsert: true
    end

    def aggregate(params)
      @col.aggregate params
    end
  end
end
