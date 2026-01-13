class Evm::Client
  def initialize(rpc_url)
    @client = Faraday.new(url: rpc_url) do |c|
      c.request :json
      c.response :json, content_type: /\bjson/
      c.adapter Faraday.default_adapter
    end
  end

  def balance(address, block_tag)
    address_valid?(address)
    result = request(Evm::Constants::METHODS[:get_balance], address, block_tag)
    wei_to_ether(from_hex(result))
  end

  def tx_count(address, block_tag)
    address_valid?(address)
    result = request(Evm::Constants::METHODS[:get_transaction_count], address, block_tag)
    from_hex(result)
  end

  def block_number
    result = request(Evm::Constants::METHODS[:block_number])
    from_hex(result)
  end

  def block_by_number(block_number, full_transaction)
    block_hex = to_hex(block_number)
    request(Evm::Constants::METHODS[:get_block_by_number], block_hex, full_transaction)
  end

  private

  def request(method, *params)
    response = @client.post do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        jsonrpc: '2.0',
        method: method,
        params: params,
        id: 1
      }
    end

    raise "#{self.class} RPC Error: #{response.status} #{response.body}" if response.body['error'] || response.status != 200

    response.body['result']
  end

  def wei_to_ether(wei)
    wei.to_f / 10**18
  end

  def to_hex(num)
    return num.prepend('0x') if num.is_a?(String)
    num.to_s(16).prepend('0x')
  end

  def from_hex(hex)
    hex.to_i(16)
  end

  # should return bool, reconsider if validation should be here
  def address_valid?(address)
    raise ArgumentError, "#{self.class} invalid address" unless address.match(/^(0x)?[0-9a-fA-F]{40}$/) && address.length == 42
  end
end
