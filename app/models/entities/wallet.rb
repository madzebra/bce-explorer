module BceExplorer
  # Wallet entity
  module Entities
    Wallet = Struct.new :id,
                        :name,
                        :balance,
                        :addresses do
      def self.create_from(params = {})
        new params['id'], params['name'],
            params['balance'], params['addresses']
      end
    end
  end
end
