lib = File.dirname(__FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# Requires all .rb file in a given directory.
def require_all path
  Dir[File.join(File.dirname(__FILE__), path, '*.rb')].each { |f| require f }
end

require 'logger'

require 'bpred/register'
require 'bpred/memory'

require_all 'bpred'
require_all 'bpred/isa'

module Bpred
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end
