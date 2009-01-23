require 'uri'

module CouchPotato
  module Persistence
    class Finder
      # finds all objects of a given type by the given attribute/value pairs
      # options: attribute_name => value pairs to search for
      # value can also be a range which will do a range search with startkey/endkey
      # WARNING: calling this methods creates a new view in couchdb if it's not present already so don't overuse this
      def find(clazz, conditions = {}, view_options = {})
        to_instances clazz, query_view(clazz, conditions, view_options_with_default_order(clazz, view_options))
      end
      
      def count(clazz, conditions = {}, view_options = {})
        query_view(clazz, conditions, view_options, '_count', count_reduce_function)['rows'].first.try(:[], 'value') || 0
      end
      
      private
      
      def view_options_with_default_order(clazz, view_options)
        if clazz.default_order
          view_options[:order] ||= clazz.default_order
        end
        view_options
      end
      
      def query_view(clazz, conditions, view_options, view_postfix = nil, reduce_fuction = nil)
        ViewQuery.new(design_document(clazz), view(conditions, view_options[:order]) + view_postfix.to_s, map_function(clazz, search_fields(conditions, view_options[:order])), reduce_fuction, conditions, view_options).query_view!
      end
      
      def db(name = nil)
        ::CouchPotato::Persistence.Db(name)
      end
      
      def design_document(clazz)
        clazz.name.underscore
      end
      
      def map_function(clazz, search_fields)
        "function(doc) {
          if(doc.ruby_class == '#{clazz}') {
            emit(
              [#{search_fields.map{|attr| "doc[\"#{attr}\"]"}.join(', ')}], doc
                );
          }
        }"
      end
      
      def count_reduce_function
        "function(keys, values) {
          return values.length;
        }"
      end
      
      def view(conditions, order)
        "by_#{view_name(conditions, order)}"
      end
      
      
      def search_fields(conditions, order)
        sorted_keys(conditions, order)
      end
      
      def sorted_keys(conditions, order)
        (order || []) | conditions.keys.sort{|x,y| x.to_s <=> y.to_s}
      end
      
      def view_name(conditions, order)
        sorted_keys(conditions, order).join('_and_')
      end
      
      def to_instances(clazz, query_result)
        query_result['rows'].map{|doc| doc['value']}.map{|json| clazz.json_create json}
      end
      
    end
  end
end