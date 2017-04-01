# frozen_string_literal: true
module ReviewAssigner
  class Graph
    attr_accessor :source, :sink
    attr_reader :size, :cap, :cost, :fi

    INF = (1<<28).freeze

    def initialize(size)
      @size = size

      @nxt = []
      @to = []
      @cost = []
      @cap = []

      @fst = Array.new(size, -1)
      @d = Array.new(size)
      @fi = Array.new(size, 0)
      @path = Array.new(size)

      @was = Heap.new do |a, b|
        d[a] <=> d[b]
      end
    end

    def resize(new_size)
      (new_size - size).times do
        fst << -1
        d << INF
        fi << 0
        path << nil
      end
      @size = new_size
    end

    def add_edge(from, to, cap:, cost:)
      id = _add_edge(from, to, cap, cost)
      _add_edge(to, from, 0, -cost)
      id
    end

    def min_cost_max_flow
      # there are no negative cost edges
      while dijkstra
        relax_path
        update_potentials
      end
    end

    def each_edge_of(v)
      edge = fst[v]
      while edge != -1
        yield to[edge], edge, cap[edge], cost[edge]
        edge = nxt[edge]
      end
    end

    def each_incomming_edge_to(v)
      edge = fst[v]
      while edge != -1
        yield to[edge], edge^1, cap[edge^1], cost[edge^1]
        edge = nxt[edge]
      end
    end

    def sink_saturated?
      each_incomming_edge_to(sink) do |from, id, cap|
        return false if cap > 0
      end
      return true
    end

    protected
      attr_reader :nxt, :fst, :to, :d, :was, :path

    private

      def _add_edge(from, to, cap, cost)
        nxt << fst[from]
        fst[from] = nxt.size - 1
        self.to << to
        self.cost << cost
        raise 'Capacity cannot be negative' if cap < 0
        self.cap << cap
        nxt.size - 1
      end

      def dijkstra
        was.erase
        size.times{|i| d[i] = INF}
        d[source] = 0
        was << source
        path_to_sink_exist = false
        while !was.empty?
          v = was.extract_min
          path_to_sink_exist = true if v == sink
          update_outgoing_edges(v)
        end
        path_to_sink_exist
      end

      def update_outgoing_edges(v)
        each_edge_of(v) do |to, id, cap, cost|
          next if cap == 0
          # puts '!!!!!!!' if cost + fi[v] - fi[to] < 0
          if d[to] > d[v] + cost + fi[v] - fi[to]
            was.delete(to)
            d[to] = d[v] + cost + fi[v] - fi[to]
            path[to] = id
            was << to
          end
        end
      end

      def relax_path
        v = sink
        min_capacity = INF
        while v != source
          min_capacity = cap[path[v]] if cap[path[v]] < min_capacity
          v = to[path[v]^1]
        end

        the_cost = 0
        v = sink
        while v != source
          the_cost += min_capacity * cost[path[v]]
          cap[path[v]] -= min_capacity
          cap[path[v]^1] += min_capacity
          v = to[path[v]^1]
        end
        # puts "Found a path of cost: #{the_cost}, capacity: #{min_capacity}"
      end

      def update_potentials
        size.times do |i|
          fi[i] += d[i]
        end
      end
  end
end
