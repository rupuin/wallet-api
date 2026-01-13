require 'rails_helper'

RSpec.describe Evm::RpcDto do
  subject do described_class.new(
      chain: chain,
      testnet: testnet,
      method: method,
      address: address,
      block_tag: block_tag,
      block_number: block_number,
      full_transaction: full_transaction
  ) end

  let(:chain) { 'ethereum' }
  let(:testnet) { 'false' }
  let(:method) { 'get_balance' }
  let(:address) { '0x1234567890abcdef1234567890abcdef12345678' }
  let(:block_tag) { 'latest' }
  let(:block_number) { '1' }
  let(:full_transaction) { 'true' }

  shared_examples 'invalid field' do |field, message|
    it "adds an error for '#{field}' with a message '#{message}'" do
      subject.valid?
      expect(subject.errors).to include(field)
      expect(subject.errors[field]).to eq(message)
    end
  end

  describe '#valid?' do
    context 'with valid params' do
      it 'does not add any errors' do
        subject.valid?
        expect(subject.errors).to be_empty
      end
    end
    context 'with invalid params' do
      context 'when chain is not supported' do
        let(:chain)  { 'non-existent' }

        it_behaves_like 'invalid field', :chain, 'unsupported chain'
      end

      context 'when method is not supported' do
        let(:method) { 'non-existent' }

        it_behaves_like 'invalid field', :method, 'unsupported method'
      end

      context 'when address is not valid' do
        let(:address) { '0x23' }

        it_behaves_like 'invalid field', :address, 'invalid evm address'
      end

      context 'when address is required but not provided' do
        let(:address) { '' }

        it_behaves_like 'invalid field', :address, 'address required'
      end

      context 'when block tag is not valid' do
        let(:block_tag) { 'invalid' }

        it_behaves_like 'invalid field', :block_tag, 'invalid block tag'
      end

      context 'when block number is required but not provided' do
        let(:block_number) { nil }
        let(:method) { 'get_block_by_number' }

        it_behaves_like 'invalid field', :block_number, 'block number required'
      end

      context 'when block number is not valid' do
        let(:block_number) { 'invalid' }
        let(:method) { 'get_block_by_number' }

        it_behaves_like 'invalid field', :block_number, 'invalid block number'
      end
    end

    context 'with missing params that can be forced to default' do
      context 'when testnet value is not provided' do
        let(:testnet) { nil }

        it 'sets testnet flag to false' do
          subject.valid?
          expect(subject.testnet).to be false
        end
      end

      context 'when block tag is not provided' do
        let(:block_tag) { nil }

        it 'sets block tag to latest' do
          subject.valid?
          expect(subject.block_tag).to eq('latest')
        end
      end
    end
  end
end
