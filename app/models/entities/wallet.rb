module BceExplorer
  # Wallet entity
  module Entities
    Wallet = Struct.new :id,
                        :name,
                        :size,
                        :balance,
                        :addresses do
      def self.create_from(params = {})
        new params['id'], params['name'], params['size'],
            params['balance'], params['addresses']
      end
    end
  end
end
