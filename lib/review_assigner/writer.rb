# frozen_string_literal: true
require 'forwardable'
require 'axlsx'

module ReviewAssigner
  class Writer
    extend Forwardable

    def initialize(input, reader, filename, assigner)
      @input = input
      @reader = reader
      @assigner = assigner
      @filename = filename
    end

    def write
      build_matrix
      build_xlsx
    end

    private

      attr_reader :pkg, :input, :assigner, :matrix, :filename, :reader
      def_delegators :assigner, :assignments, :new_experts
      def_delegators :input, :experts, :objects

      def build_matrix
        @matrix = Array.new(3 + objects) { Array.new(2 + experts + new_experts) }
        build_headers
        build_new_experts
        build_main_assignments
      end

      def build_headers
        experts.times do |col|
          3.times do |row|
            copy(col + 3, row + 1)
          end
        end

        objects.times do |row|
          2.times do |col|
            copy(col + 1, row + 4)
          end
        end
      end

      def build_new_experts
        new_experts.times do |i|
          id = experts + i + 1
          set(2 + id, 1, "НЭ#{id}")
        end
        assignments.each do |expert, object, type|
          next if expert < experts
          set_assignment(expert, object, assignment_type(expert, type))
          add(3 + expert, 2, 1) if type == :paid
        end
      end

      def build_main_assignments
        assignments.each do |expert, object, type|
          next if expert >= experts
          set_assignment(expert, object, assignment_type(expert, type))
        end
      end

      def assignment_type(expert, type)
        case type
        when :paid
          'Д'
        when :contract
          'Э'
        when :assigned
          'x'
        end
      end

      def set_assignment(expert, object, value)
        set(3 + expert, 4 + object, value)
      end

      def copy(col, row)
        set(col, row, reader.at(col, row))
      end

      def set(col, row, value)
        matrix[row - 1][col - 1] = value
      end

      def add(col, row, value)
        matrix[row - 1][col - 1] ||= 0
        matrix[row - 1][col - 1] += value
      end

      def build_xlsx
        Axlsx::Package.new do |p|
          p.workbook.add_worksheet(name: 'Experts') do |sheet|
            matrix.each do |row|
              sheet.add_row row
            end
          end
          p.serialize(filename)
        end
      end
  end
end
