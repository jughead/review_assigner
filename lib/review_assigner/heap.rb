# frozen_string_literal: true
module ReviewAssigner
  # Taken from: https://github.com/apleroy/minimum_spanning_tree_google_maps_api/blob/master/app/classes/min_heap.rb
  # Adjusted by Alexander Fedulin
  class Heap
    # initialize an empty array with nil at the 0 index (to make math easier)
    def initialize(&block)
      @elements = [nil]
      @element_position_map = Hash.new
      @comparator = block
    end

    # override add to array method - preserve the min heap property
    def <<(element)
      # puts "adding #{element}"
      @elements << element
      @element_position_map[element] = @elements.size - 1

      sift_up(@elements.size - 1)
    end

    def empty?
      count == 0
    end

    def count
      return @elements.size - 1 # do not count the nil element at position[0]
    end

    def peek_min
      return @elements[1]
    end

    def extract_min
      # puts "extracting min"
      # exchange the minimum element with the last one in the list
      exchange(1, @elements.size - 1)
      # remove the last element
      min_element = @elements.pop
      @element_position_map.delete(min_element)
      # make sure the tree is ordered - call the helper method to sift down the new root node into appropriate position
      sift_down(1)
      # return the min element
      return min_element
    end

    def has?(element)
      return @element_position_map.has_key?(element)
    end

    def delete(element)
      element_position = @element_position_map[element]

      unless element_position.nil?
        # puts "removing element #{element} as position #{element_position}"
        # exchange the element with the last one in the list
        exchange(element_position, @elements.size - 1)

        # remove the last element
        element_to_remove = @elements.pop
        @element_position_map.delete(element_to_remove)

        # make sure the tree is ordered - call the helper method to sift down the new root node into appropriate position
        sift_down(element_position)
        sift_up(element_position)

        return element_to_remove
      end
    end

    def erase
      @elements.clear
      @element_position_map.clear
      @elements << nil
    end

    def print_heap
      puts 'printing min heap'
      @elements.each do |element|
        if element.nil?
          puts 'nil'
        else
          puts element
        end
      end
    end

    private

      def sift_up(id)
        return if id >= @elements.size
        # we get the parent of the id so we can see if it is larger than the new node
        parent_id = id >> 1
        # if the id is 1 - no need to continue
        return if id <= 1
        # if the element's parent is less than the current element we return (the min heap property is preserved)
        return if compare(@elements[id], @elements[parent_id]) >= 0
        # otherwise we exchange the two - the smaller element goes into the parent location
        exchange(id, parent_id)
        # and we recursively call this method to keep sifting up the smaller element
        sift_up(parent_id)
      end

      def sift_down(id)
        # get the first child (the left child)
        child_id = id << 1
        # if the child id is greater than the size of the array it does not exist and we can return
        return if child_id > @elements.size - 1
        left_child = @elements[child_id]
        right_child = @elements[child_id | 1]
        # find the smallest of the two children
        if child_id < @elements.size - 1 && compare(right_child, left_child) < 0
          child_id |= 1
        end
        # if the element at the current id is smaller than the children, return
        return if compare(@elements[id], @elements[child_id]) <= 0
        # exchange the larger id with the smaller child
        exchange(id, child_id)
        # keep sifting down, this time from the farther along child id
        sift_down(child_id)
      end

      # exchange two elements within the minheap
      def exchange(source_id, target_id)
        a, b = @elements[source_id], @elements[target_id]
        @elements[source_id], @elements[target_id] = b, a
        @element_position_map[a], @element_position_map[b] = @element_position_map[b], @element_position_map[a]
      end

      def compare(a, b)
        @comparator.call(a, b)
      end
  end
end
