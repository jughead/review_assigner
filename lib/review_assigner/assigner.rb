class Assigner
  attr_reader :assignments, :new_experts

  TOUCHED_EXPERT_PRIORITY = 100_000.freeze

  def initialize(input)
    @input = input
    @used = Set.new
    @assignments = []
    @new_experts = 0
  end

  def solve
    init_experts
    init_objects
    apply_existing_assignments
    assign_bought_experts

    if has_unreviewed_object?
      buy_over_contract_expertise
    end

    while has_unreviewed_object?
      load_expert(buy_expert)
    end
  end

  private

    class Object < Struct.new(:id, :reviews)
      def <=>(other)
        other.reviews <=> reviews
      end

      def positive?
        reviews.positive?
      end
    end

    attr_reader :input

    def init_experts
      @bought_reviews = input.bought_reviews.dup
      @expert_priorities = Hash.new(0)
      input.experts.times do |expert|
        @expert_priorities[expert] = @bought_reviews[expert]
      end
    end

    def init_objects
      @objects = SortedSet.new
      @object_map = {}

      input.objects.times do |id|
        obj = Object.new(id, input.required_reviews[id])
        @objects << obj
        @object_map[id] = obj
      end
    end

    def review_object(object)
      @objects.delete(object)
      object.reviews -= 1
      @objects << object
    end

    def add(expert, object, type)
      review_object(object)
      @bought_reviews[expert] -= 1
      assignments << [expert, object.id, type]
      @used << [expert, object.id]
    end

    def object(id)
      @object_map[id]
    end

    def apply_existing_assignments
      input.assignments.each do |expert, obj_id|
        @expert_priorities[expert] = TOUCHED_EXPERT_PRIORITY
        add expert, object(obj_id), :assigned
        raise "Объект ##{object + 1} имеет слишком много уже назначенных экспертиз" if object(obj_id).reviews < 0
        raise "Эксперт ##{expert + 1} имеет слишком много уже назначенных экспертиз" if @bought_reviews[expert] < 0
      end
    end

    def load_expert(expert)
      @objects.each do |object|
        next if object_reviewed?(object)
        break if expert_loaded?(expert)

        unless assigned?(expert, object)
          type = if expert < input.experts
            :contract
          else
            :paid
          end
          add expert, object, type
        end
      end
    end

    def assign_bought_experts
      @expert_priorities.sort_by{|k| -k[1]}.each do |expert, _|
        load_expert(expert)
      end
    end

    def assigned?(expert, object)
      @used.include?([expert, object.id])
    end

    def object_reviewed?(object)
      object.reviews == 0
    end

    def expert_loaded?(expert)
      @bought_reviews[expert] == 0
    end

    def buy_over_contract_expertise
      @objects.each do |object|
        next if object_reviewed?(object)
        input.experts.times do |expert|
          next if assigned?(expert, object)
          next if input.limited_reviews[expert]
          break if object_reviewed?(object)
          buy_review(expert)
          add expert, object, :paid
        end
      end
    end

    def buy_review(expert)
      @bought_reviews[expert] += 1
    end

    def has_unreviewed_object?
      @objects.first.reviews.positive?
    end

    def buy_expert
      expert = @new_experts
      @new_experts += 1
      @bought_reviews << @objects.count(&:positive?)
      input.experts + expert
    end
end
