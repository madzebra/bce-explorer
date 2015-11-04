module BceExplorer
  # richlist sync routine
  class RichList
    def initialize(blockexplorer:, database:)
      @be = blockexplorer
      @db = database
    end

    def sync!
      ((@db.info.blocks + 1)..@be.block.count).each do |blk_num|
        block = @be.block(blk_num).decode_with_tx
        @db.block << block
        block['tx'].each do |tx|
          sync_transaction tx
        end
        @db.info.blocks = blk_num
      end
    end

    private

    def sync_transaction(tx)
      tx['blockindex'] = blk_num
      sync_inputs tx
      sync_outputs tx
      sync_wallets tx
      @db.tx << tx
    end

    def sync_inputs(tx)
      tx['inputs'].each do |input|
        address = input['address']
        next if generation? address
        @db.address.sub address, input['value'].to_f
        @db.tx_address << { address: address, txid: tx['txid'] }
      end
    end

    def sync_outputs(tx)
      tx['outputs'].each do |output|
        address = output['address']
        next if stake? address
        @db.address.add address, output['value'].to_f
        @db.tx_address << { address: address, txid: tx['txid'] }
      end
    end

    def sync_wallets(tx)
      @db.wallet.merge! extract_addresses_from(tx['inputs'])

      extract_addresses_from(tx['outputs'])
        .each { |address| @db.wallet.merge! address }
    end

    def extract_addresses_from(source)
      source
        .map { |row| row['address'] }
        .reject { |address| generation?(address) || stake?(address) }
    end

    def stake?(address)
      address == 'stake'
    end

    def generation?(address)
      address.include? 'Generation'
    end
  end
end
