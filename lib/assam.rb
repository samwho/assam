lib = File.dirname(__FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# Requires all .rb file in a given directory.
def require_all path
  Dir[File.join(File.dirname(__FILE__), path, '*.rb')].each { |f| require f }
end

require 'logger'

require 'assam/register'
require 'assam/memory'

require_all 'assam'
require_all 'assam/isa'

module Assam
  def self.logger
    unless @logger
      @logger = Logger.new(STDOUT)

      if ENV['DEBUG']
        @logger.level = Logger::DEBUG
      else
        @logger.level = Logger::INFO
      end
    end

    @logger
  end
end
