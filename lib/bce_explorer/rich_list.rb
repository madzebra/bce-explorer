module BceExplorer
  # richlist sync routine
  class RichList
    def initialize(options = {})
      @be = options[:blockexplorer]
      @db = options[:database]
      fail if @be.nil? || @db.nil?
    end

    def sync!
      ((@db.info.blocks + 1)..@be.block.count).each do |blk_num|
        @be.block(blk_num).decode_with_tx['tx'].each do |tx|
          sync_wallets tx
          sync_inputs tx
          sync_outputs tx
          @db.transaction << tx
        end
        @db.info.blocks = blk_num
      end
    end

    private

    def sync_inputs(tx)
      tx['inputs'].each do |input|
        next if input['address'].include? 'Generation'
        @db.address[input['address']] -= input['value'].to_f
        @db.address.add_tx address: input['address'], txid: tx['txid']
      end
    end

    def sync_outputs(tx)
      tx['outputs'].each do |output|
        next if output['address'] == 'stake'
        @db.address[output['address']] += output['value'].to_f
        @db.address.add_tx address: output['address'], txid: tx['txid']
      end
    end

    def sync_wallets(tx)      
      addresses = tx['inputs'].
        map {|inp| inp['address']}.
        reject {|a| a.include? 'Generation'}

      @db.wallet.merge addresses unless addresses.empty?
    end
  end
end
