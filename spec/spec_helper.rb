require File.join(File.dirname(__FILE__), '..', 'lib', 'assam')

require 'bundler'
Bundler.require :test

module SpecHelpers
  def self.included base
    base.let(:processor) { Assam::Processor.new }
    base.let(:ram)       { processor.ram }

    base.let(:eax) { processor.registers[:eax] }
    base.let(:ebx) { processor.registers[:ebx] }
    base.let(:ecx) { processor.registers[:ecx] }
    base.let(:edx) { processor.registers[:edx] }
  end
end

RSpec.configure do |config|
  config.include SpecHelpers
end
