# frozen_string_literal: true
require 'roo'

module ReviewAssigner
  class Reader
    def initialize(filename)
      @doc = Roo::Spreadsheet.open(filename, extension: File.extname(filename))
      @doc.default_sheet = @doc.sheets.first
    end

    def at(i, j)
      @doc.cell(j, i)
    end
  end
end
