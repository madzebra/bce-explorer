module BceExplorer
  # sync db routines
  class Sync
    def initialize(blockexplorer:, database:)
      @be = blockexplorer
      @db = database
    end

    def sync_db
      @block_count = @be.block.count
      ((@db.info.blocks + 1)..@block_count).each do |blk_num|
        block = @be.block(blk_num).decode_with_tx
        @db.block << block
        block['tx'].each_with_index do |tx, i|
          tx['type'] = calc_tx_type block, i
          sync_transaction tx, blk_num
        end
      end
      sync_info
    end

    private

    def sync_info
      @db.info.blocks = @block_count
      @db.info.network = @be.network_info
      @db.info.peers = @be.network_peer_info
    end

    def sync_transaction(tx, blk_num)
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
        type = (tx['type'] == 'minted') ? 'minted' : 'in'
        @db.address.sub address, input['value'].to_f, (type == 'minted')
        @db.tx_address << { address: address, txid: tx['txid'], type: type }
      end
    end

    def sync_outputs(tx)
      tx['outputs'].each do |output|
        address = output['address']
        next if stake? address
        type = (tx['type'] == 'minted') ? 'minted' : 'out'
        @db.address.add address, output['value'].to_f, (type == 'minted')
        @db.tx_address << { address: address, txid: tx['txid'], type: type }
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

    def calc_tx_type(block, i)
      if ((block['flags'].include? 'stake') && (i < 2)) || (i < 1)
        'minted'
      else
        'out'
      end
    end
  end
end
