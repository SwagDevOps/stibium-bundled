# frozen_string_literal: true

# Locate a command
module Which
  autoload(:Pathname, 'pathname')

  protected

  # Locate a command
  #
  # @param cmd [String]
  # @param env [Hash{String => String}]
  #
  # @return [Array<Pathname>]
  def which(cmd, env: ENV.to_h.dup)
    env.fetch('PATH').split(':').map { |s| Pathname.new(s).join(cmd) }.select { |f| f.file? and f.executable? }
  end

  class << self
    def call(*args, **kwargs)
      self.yield_self do |mod|
        Class.new { include mod }.new.__send__(:which, *args, **kwargs)
      end
    end
  end
end
