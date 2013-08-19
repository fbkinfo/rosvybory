module ActiveRecord
  module Sanitization
    module ClassMethods
      # Sanitizes a hash of attribute/value pairs into SQL conditions for a WHERE clause.
      #   { name: "foo'bar", group_id: 4 }
      #     # => "name='foo''bar' and group_id= 4"
      #   { status: nil, group_id: [1,2,3] }
      #     # => "status IS NULL and group_id IN (1,2,3)"
      #   { age: 13..18 }
      #     # => "age BETWEEN 13 AND 18"
      #   { 'other_records.id' => 7 }
      #     # => "`other_records`.`id` = 7"
      #   { other_records: { id: 7 } }
      #     # => "`other_records`.`id` = 7"
      # And for value objects on a composed_of relationship:
      #   { address: Address.new("123 abc st.", "chicago") }
      #     # => "address_street='123 abc st.' and address_city='chicago'"
      def sanitize_sql_hash_for_conditions(attrs, default_table_name = self.table_name)
        attrs = expand_hash_conditions_for_aggregates(attrs)

        table = Arel::Table.new(table_name, arel_engine).alias(default_table_name)
        PredicateBuilder.build_from_hash(self, attrs, table).map { |b|
          connection.visitor.accept b
        }.join(' AND ')
      end
      alias_method :sanitize_sql_hash, :sanitize_sql_hash_for_conditions
    end
  end
end