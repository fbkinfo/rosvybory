#Ransack.configure do |config|
#  config.add_predicate 'bw_and', # Name your predicate
#                       # What non-compound ARel predicate will it use? (eq, matches, etc)
#                       :arel_predicate => 'bw_and',
#                       # Format incoming values as you see fit. (Default: Don't do formatting)
#                       :formatter => proc {|v| v.inject{|sum,x| sum.to_i | x.to_i }},
#                       # Validate a value. An "invalid" value won't be used in a search.
#                       # Below is default.
#                       :validator => proc {|v| v.present? && v != 0},
#                       # Should compounds be created? Will use the compound (any/all) version
#                       # of the arel_predicate to create a corresponding any/all version of
#                       # your predicate. (Default: true)
#                       #:compounds => true,
#                       # Force a specific column type for type-casting of supplied values.
#                       # (Default: use type from DB column)
#                       :type => :integer
#  #Arel::Nodes::Equality('test', any_nicknames_function)
#end