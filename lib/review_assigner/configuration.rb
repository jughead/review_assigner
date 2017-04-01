# frozen_string_literal: true
module ReviewAssigner
  class Configuration
    attr_writer :reader, :parser, :writer

    def initialize
      @reader = 'ReviewAssigner::Reader'
      @parser = 'ReviewAssigner::Parser'
      @writer = 'ReviewAssigner::Writer'
    end

    def reader
      Object.const_get(@reader)
    end

    def writer
      Object.const_get(@writer)
    end

    def parser
      Object.const_get(@parser)
    end
  end
end
