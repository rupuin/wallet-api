class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def error_response(dto)
    {
      success: false,
      errors: dto.errors,
      meta: build_meta(dto)
    }
  end

  def success_response(dto, result)
    {
      success: true,
      result: result,
      meta: build_meta(dto)
    }
  end

  def build_meta(dto)
    {
      method: Evm::Constants::METHODS[dto.method],
      chain: dto.chain,
      testnet: dto.testnet,
      address: dto.address,
      block_tag: dto.block_tag,
      block_number: dto.block_number,
      full_transaction: dto.full_transaction,
      timestamp: Time.now.utc.iso8601
    }.compact
  end
end
