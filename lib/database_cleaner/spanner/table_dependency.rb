require "tsort"

module DatabaseCleaner
  module Spanner
    class TableDependency < Hash
      include TSort

      def initialize
        @parents = Hash.new { |h, k| h[k] = Set.new }
      end

      def add_child(parent, child)
        store(parent, Set.new) unless key?(parent)

        return if child.nil?

        store(child, Set.new) unless key?(child)

        fetch(parent).add(child)

        @parents[child].add(parent)
      end

      def add_children(parent, children)
        store(parent, children || Set.new)
        children.each { |child| @parents[child].add(parent) }
      end

      def divide
        groups = []
        visited = Set.new

        each_table do |table|
          next if visited.include?(table)

          group = TableDependency.new
          dfs(table, group, visited)
          groups << group
        end

        groups
      end

      alias_method :each_table, :each_key

      def tsort_each_child(node, &block)
        fetch(node).each(&block)
      end

      alias_method :tsort_each_node, :each_key

      private

      def dfs(table, group, visited)
        visited.add(table)
        children = fetch(table)
        group.add_children(table, children)

        related_tables = if @parents.key?(table)
          children + @parents[table]
        else
          children
        end

        related_tables.each do |table|
          next if visited.include?(table)
          dfs(table, group, visited)
        end
      end
    end
  end
end
