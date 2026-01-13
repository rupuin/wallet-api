class Blockchain::Evm::Rpc
  attr_reader :chain, :method, :testnet, :address, :block_tag, :block_number, :full_transaction

  def self.for(...)
    new(...).call
  end

  def initialize(dto)
    @dto = dto
  end

  def call
    case @dto.method
    when :get_balance
      client.balance(@dto.address, @dto.block_tag)
    when :get_transaction_count
      client.tx_count(@dto.address, @dto.block_tag)
    when :block_number
      client.block_number
    when :get_block_by_number
      client.block_by_number(@dto.block_number, @dto.full_transaction)
    else
      raise ArgumentError, "#{self.class} unsupported method: #{@dto.method}"
    end
  end

  private

  def rpc_url
    Blockchain::Evm::Endpoint.for(@dto.chain, @dto.testnet)
  end

  def client
    @client ||= Evm::Client.new(rpc_url)
  end
end
