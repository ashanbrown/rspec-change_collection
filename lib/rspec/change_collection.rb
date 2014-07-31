require 'rspec/change_collection/version'
require 'rspec/core'
require 'rspec/expectations'

module RSpec::Matchers
  module ChangeCollection
    class Change < RSpec::Matchers::BuiltIn::Change
      def initialize(receiver=nil, message=nil, &block)
        @expected_to_include = []
        @expected_to_exclude = []

        @missing_original_items = []
        @extra_original_items = []

        @missing_final_items = []
        @extra_final_items = []

        super
      end

      def matches?(*)
        @parent_matches = super

        if expect_collection_to_change?
          actual_before = @change_details.actual_before
          actual_after = @change_details.actual_after

          if actual_before.respond_to?(:to_ary)
            @missing_original_items = extract_items(@expected_to_exclude) - actual_before
            @missing_original_items += reject_procs(actual_before, @expected_to_exclude)
            @extra_original_items = select_items(actual_before, @expected_to_include) & actual_before
          end

          if actual_after.respond_to?(:to_ary)
            @missing_final_items = extract_items(@expected_to_include) - actual_after
            @missing_final_items += reject_procs(actual_after, @expected_to_include)
            @extra_final_items = select_items(actual_after, @expected_to_exclude) & actual_after
          end
        end

        @parent_matches && ![
          @missing_original_items,
          @extra_original_items,
          @missing_final_items,
          @extra_final_items
        ].map(&:empty?).include?(false)
      end

      def failure_message
        if @parent_matches
          message =  ""
        else
          message = super
        end

        if expect_collection_to_change?
          array_messages = []
          append_array_message = lambda do |message, values|
            array_messages << "#{message}#{values.inspect}" if values.length > 0
          end
          append_array_message.call(
            "the original collection should have included:     ",
            @missing_original_items
          )
          append_array_message.call(
            "the original collection should not have included: ",
            @extra_original_items
          )
          append_array_message.call(
            "the final collection should have included:        ",
            @missing_final_items
          )
          append_array_message.call(
            "the final collection should not have included:    ",
            @extra_final_items
          )
          append_array_message.call(
            "the original collection was:                      ",
            @change_details.actual_before
          )
          append_array_message.call(
            "the final collection was:                         ",
            @change_details.actual_after
          )
          message << "\n#{array_messages.join "\n"}\n" unless array_messages.empty?
          message
        end

        message
      end

      def failure_message_when_negated
        return "Matcher does not support negation" if expect_collection_to_change?
        super
      end

      def to_include(*items, &block)
        check_arguments(__method__, *items, &block)
        @expected_to_include << items
        @expected_to_include << block if block
        self
      end

      def to_exclude(*items, &block)
        check_arguments(__method__, *items, &block)
        @expected_to_exclude << items
        @expected_to_exclude << block if block
        self
      end

      private

      def callable?(rule)
        rule.respond_to?(:call)
      end

      def extract_items(rules)
        rules.reject { |rule| callable?(rule) }.flatten(1)
      end

      def reject_procs(items, rules)
        rules.select { |rule| callable?(rule) }.reject { |proc| items.any? { |item| proc.call(item) }}
      end

      def select_items(items, rules)
        items.select { |item| item_in_rules?(item, rules) }
      end

      def item_in_rules?(item, rules)
        rules.any? do |rule|
          if callable?(rule)
            rule.call(item)
          else
            rule.include?(item)
          end
        end
      end

      def expect_collection_to_change?
        [@expected_to_include, @expected_to_exclude].map(&:empty?).include?(false)
      end

      def safe_sort(array)
        array.sort rescue array
      end

      def check_arguments(method, *items, &block)
        if block && !items.empty?
          raise(
            ArgumentError,
            "`#{method}` requires either objects " \
            "(`to_include(obj1, obj2, ...)`) or a block (`to_include { }`) but not both. "
          )
        end
      end
    end
  end

  def change_with_collection(receiver=nil, message=nil, &block)
    RSpec::Matchers::ChangeCollection::Change.new(receiver, message, &block)
  end

  alias_method :change_without_collection, :change_with_collection
  alias_method :change, :change_with_collection
end

RSpec.configure do |rspec|
  rspec.extend RSpec::Matchers::ChangeCollection
  rspec.backtrace_exclusion_patterns << %r(/lib/rspec/change_collection)
end

RSpec::SharedContext.send(:include, RSpec::Matchers::ChangeCollection)
