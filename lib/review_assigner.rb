# frozen_string_literal: true
require 'review_assigner/version'
require 'review_assigner/configuration'
require 'review_assigner/assigner'
require 'review_assigner/reader'
require 'review_assigner/writer'
require 'review_assigner/parser'

module ReviewAssigner
  module_function

  def config
    @configuration ||= Configuration.new
  end

  def configure
    yield config
  end

  def assign_excel(input_filename, output_filename)
    reader = config.reader.new(input_filename)
    parser = config.parser.new(reader)
    parser.parse
    assigner = Assigner.new(parser)
    assigner.solve
    writer = config.writer.new(parser, reader, output_filename, assigner)
    writer.write
  end
end
