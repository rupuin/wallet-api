require 'rails_helper'

RSpec.describe Blockchain::Evm::Rpc do
  subject { described_class.for(dto) }

  let(:chain) { :blockchain }
  let(:testnet) { false }
  let(:method) { :get_balance }
  let(:address) { '0x1111111111111111111111111111111111111111' }
  let(:block_tag) { 'latest' }
  let(:block_number) { '0x1' }
  let(:full_transaction) { true }

  let(:dto) do
    instance_double(
      Evm::RpcDto,
      chain: chain,
      testnet: testnet,
      method: method,
      address: address,
      block_tag: block_tag,
      block_number: block_number,
      full_transaction: full_transaction,
      errors: {}
    )
  end

  let(:rpc_url) { 'https://mainnet-url/secret' }
  let(:client) { instance_double(Evm::Client) }

  before do
    allow_any_instance_of(described_class).to receive(:rpc_url).and_return(rpc_url)
    allow_any_instance_of(described_class).to receive(:client).and_return(client)
  end

  context 'when getting balance' do
    it 'calls client balance method with correct parameters' do
      expect(client).to receive(:balance).with(address, block_tag)
      subject
    end
  end

  context 'when getting transaction count' do
    let(:method) { :get_transaction_count }

    it 'calls client tx_count method with correct parameters' do
      expect(client).to receive(:tx_count).with(address, block_tag)
      subject
    end
  end

  context 'when getting block number' do
    let(:method) { :block_number }

    it 'calls client block_number method' do
      expect(client).to receive(:block_number)
      subject
    end
  end

  context 'when getting block by number' do
    let(:method) { :get_block_by_number }

    it 'calls client block_by_number method with correct parameters' do
      expect(client).to receive(:block_by_number).with(block_number, full_transaction)
      subject
    end
  end

  context 'with unsupported method' do
    let(:method) { :unsupported_method }

    it 'raises an ArgumentError' do
      expect { subject }.to raise_error(ArgumentError, "#{described_class} unsupported method: #{method}")
    end
  end
end
