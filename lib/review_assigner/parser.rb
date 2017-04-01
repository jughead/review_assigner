# frozen_string_literal: true
module ReviewAssigner
  class Parser
    EXPERTS_START_COL = 3.freeze
    EXPERTS_START_ROW = 1.freeze
    OBJECTS_START_COL = 1.freeze
    OBJECTS_START_ROW = 4.freeze
    REVIEWS_BOUGHT_START_COL = 3.freeze
    REVIEWS_BOUGHT_START_ROW = 2.freeze
    LIMITED_REVIEWS_START_ROW = 3.freeze
    LIMITED_REVIEWS_START_COL = 3.freeze
    ASSIGNMENTS_START_ROW = 4.freeze
    ASSIGNMENTS_START_COL = 3.freeze
    REQUIRED_REVIEWS_START_COL = 2.freeze
    REQUIRED_REVIEWS_START_ROW = 4.freeze

    attr_reader :experts, :objects, :bought_reviews, :limited_reviews,
      :assignments, :required_reviews

    def initialize(reader)
      @reader = reader
      @experts = 0
      @objects = 0
    end

    def parse
      parse_experts
      parse_objects
      parse_bought_reviews
      parse_limited_reviews
      parse_required_reviews
      parse_existing_assignments
    end

    private
      attr_reader :reader

      def parse_experts
        @experts += 1 while reader.at(EXPERTS_START_COL + @experts, EXPERTS_START_ROW).to_s.length > 0
      end

      def parse_objects
        @objects += 1 while reader.at(OBJECTS_START_COL, OBJECTS_START_ROW + @objects).to_s.length > 0
      end

      def parse_bought_reviews
        @bought_reviews = Array.new(@experts)
        @experts.times do |col|
          @bought_reviews[col] = reader.at(REVIEWS_BOUGHT_START_COL + col, REVIEWS_BOUGHT_START_ROW).to_i
        end
      end

      def parse_limited_reviews
        @limited_reviews = Array.new(@experts)
        @experts.times do |col|
          @limited_reviews[col] = reader.at(LIMITED_REVIEWS_START_COL + col, LIMITED_REVIEWS_START_ROW).to_s.length > 0
        end
      end

      def parse_required_reviews
        @required_reviews = Array.new(@objects)
        @objects.times do |row|
          @required_reviews[row] = reader.at(REQUIRED_REVIEWS_START_COL, REQUIRED_REVIEWS_START_ROW + row).to_i
        end
      end

      def parse_existing_assignments
        @assignments = []
        @experts.times do |col|
          @objects.times do |row|
            if reader.at(ASSIGNMENTS_START_COL + col, ASSIGNMENTS_START_ROW + row).to_s == 'x'
              @assignments << [col, row]
            end
          end
        end
      end
  end
end
