class Evm::ResourcesDto
  attr_accessor :methods, :chains

  def initialize(methods, chains)
    @methods = self.class.format_methods(methods)
    @chains = self.class.format_chains(chains)
  end

  def self.from_constants
    new(Evm::Constants::METHODS, Evm::Constants::CHAINS)
  end

  def to_h
    {
      'methods' => methods,
      'chains' => chains
    }
  end

  private

  def self.format_methods(methods)
    methods.map { |key, value| key.to_s }
  end

  def self.format_chains(chains)
    chains.deep_transform_keys(&:to_s)
  end
end
