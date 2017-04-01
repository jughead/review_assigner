# frozen_string_literal: true
require 'forwardable'

module ReviewAssigner
  class FlowAssigner
    extend Forwardable
    attr_reader :assignments, :new_experts

    def initialize(input)
      @input = input
      @required_reviews = input.required_reviews.dup
      @bought_reviews = input.bought_reviews.dup
      @assignments = Set.new
    end

    def solve
      apply_existing_assignments
      build_graph
      find_minimal_additional_reviews
      add_additional_experts
      fetch_assignments
    end

    private

      attr_reader :input, :graph
      attr_reader :required_reviews, :bought_reviews

      def_delegators :input, :objects, :experts, :limited_reviews

      def apply_existing_assignments
        input.assignments.each do |expert, object|
          required_reviews[object] -= 1
          bought_reviews[expert] -= 1
          raise "Объект ##{object + 1} имеет слишком много уже назначенных экспертиз" if required_reviews[object] < 0
          raise "Эксперт ##{expert + 1} имеет слишком много уже назначенных экспертиз" if bought_reviews[expert] < 0

          assignments << [expert, object, :assigned]
        end
      end

      def build_graph
        @graph = Graph.new(experts + objects + 2)
        graph.source = 0
        graph.sink = experts + objects + 1
        add_edges_to_experts
        add_edges_from_objects
        add_assignment_edges
      end

      def add_edges_to_experts
        (0..experts-1).to_a.zip(bought_reviews).
          sort{|a, b| a[1] <=> b[1]}.each do |expert, reviews|
          graph.add_edge(graph.source, expert + 1, cap: reviews, cost: 0)
          unless limited_reviews[expert]
            graph.add_edge(graph.source, expert + 1, cap: objects, cost: 1)
          end
        end
      end

      def add_edges_from_objects
        objects.times do |i|
          graph.add_edge(experts + i + 1, graph.sink, cap: required_reviews[i], cost: 0)
        end
      end

      def add_assignment_edges
        experts.times do |i|
          objects.times do |j|
            unless input.assignments.include?([i, j])
              graph.add_edge(i + 1, experts + j + 1, cap: 1, cost: 0)
            end
          end
        end
      end

      def find_minimal_additional_reviews
        graph.min_cost_max_flow
      end

      def count_additional_experts
        max_cap = 0
        graph.each_incomming_edge_to(graph.sink) do |from, id, cap, cost|
          max_cap = cap if cap > max_cap
        end
        @new_experts = max_cap
        # puts "Gonna add new experts: #{new_experts}"
      end

      def add_new_expert
        graph.resize(graph.size + 1)
        graph.add_edge(graph.source, graph.sink + new_experts + 1, cap: objects, cost: 1)
        max_fi = nil
        objects.times do |j|
          max_fi = graph.fi[experts + j + 1] if !max_fi || max_fi < graph.fi[experts + j + 1]
          graph.add_edge(graph.sink + new_experts + 1, experts + j + 1, cap: 1, cost: 0)
        end
        graph.fi[graph.sink + new_experts + 1] = max_fi if max_fi
        @new_experts += 1
      end

      def add_additional_experts
        @new_experts = 0
        while !graph.sink_saturated?
          add_new_expert
          graph.min_cost_max_flow
        end
      end

      def find_additional_and_contract_counts(vertex)
        additional = 0
        contract = 0
        graph.each_incomming_edge_to(vertex) do |from, id, cap, cost|
          next if from != graph.source
          if cost == 0
            contract = graph.cap[id^1]
          elsif cost == 1
            additional = graph.cap[id^1]
          end
        end
        [additional, contract]
      end

      def fetch_assignments
        experts.times do |i|
          additional, contract = find_additional_and_contract_counts(i + 1)
          build_expert_assignments(i, i + 1, additional, contract)
        end
        new_experts.times do |i|
          additional, contract = find_additional_and_contract_counts(graph.sink + i + 1)
          build_expert_assignments(experts + i, graph.sink + i + 1, additional, contract)
        end
      end

      def build_expert_assignments(expert, v, additional, contract)
        graph.each_edge_of(v) do |to, id, cap, cost|
          next unless experts + 1 <= to && to <= experts + objects
          next unless cap == 0
          if contract > 0
            assignments << [expert, to - experts - 1, :contract]
            contract -= 1
          elsif additional > 0
            assignments << [expert, to - experts - 1, :paid]
          end
        end
      end

  end
end
