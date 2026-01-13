class Evm::RpcDto
  attr_reader :method, :chain, :testnet, :address, :block_tag, :block_number, :full_transaction, :errors

  VALID_CHAINS = Evm::Constants::CHAINS.keys
  VALID_METHODS = Evm::Constants::METHODS.keys
  VALID_BLOCK_TAGS = Evm::Constants::BLOCK_TAGS
  ADDRESS_REQUIRED_METHODS = %i[get_balance get_transaction_count].freeze
  BLOCK_NUMBER_REQUIRED_METHODS = %i[get_block_by_number].freeze

  def initialize(
    chain:,
    method:,
    testnet: false,
    address: nil,
    block_tag: nil,
    block_number: nil,
    full_transaction: true
  )
    @chain = chain.to_sym
    @testnet = ActiveModel::Type::Boolean.new.cast(testnet)
    @method = method.to_sym
    @address = address
    @block_tag = block_tag
    @block_number = block_number
    @full_transaction = ActiveModel::Type::Boolean.new.cast(full_transaction)
    @errors = {}
  end

  def valid?
    validate_chain
    validate_testnet
    validate_method
    validate_address
    validate_block_tag
    validate_block_number
    validate_full_transaction

    @errors.empty?
  end

  private

  def validate_chain
    add_error(:chain, 'unsupported chain') unless VALID_CHAINS.include?(@chain)
  end

  def validate_testnet
    return @testnet = false if @testnet.blank?
    add_error(:testnet, 'invalid testnet value') unless [true, false].include?(@testnet)
  end

  def validate_method
    add_error(:method, 'unsupported method') unless VALID_METHODS.include?(@method)
  end

  def validate_address
    return unless ADDRESS_REQUIRED_METHODS.include?(@method)
    return add_error(:address, 'address required') if @address.blank?
    add_error(:address, 'invalid evm address') unless @address.match(/^(0x)?[0-9a-fA-F]{40}$/)
  end

  def validate_block_tag
    return @block_tag = 'latest' if @block_tag.blank?
    add_error(:block_tag, 'invalid block tag') unless VALID_BLOCK_TAGS.include?(@block_tag)
  end

  def validate_block_number
    return unless BLOCK_NUMBER_REQUIRED_METHODS.include?(@method)
    return add_error(:block_number, 'block number required') if @block_number.blank?
    add_error(:block_number, 'invalid block number') unless @block_number.to_s.match?(/^\d+$/) && @block_number.to_i.positive?
  end

  def validate_full_transaction
    return @full_transaction = true if @full_transaction.blank?
    add_error(:testnet, 'invalid full_transaction value') unless [true, false].include?(@full_transaction)
  end

  def add_error(field, message)
    @errors[field] = message
  end
end
