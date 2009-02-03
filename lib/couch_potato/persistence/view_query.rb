module CouchPotato
  module Persistence

    class ViewQuery
      def initialize(design_document_name, view_name, map_function, reduce_function = nil, conditions = {}, view_options = {})
        @design_document_name = design_document_name
        @view_name = view_name
        @map_function = map_function
        @reduce_function = reduce_function
        @conditions = conditions
        @view_options = view_options.dup
        @order = @view_options.delete(:order)
      end
      
      def query_view!
        begin
          query_view
        rescue RestClient::ResourceNotFound => e
          create_view
          query_view
        end
      end
      
      private
      
      def create_view
        # in couchdb 0.9 we could use only 1 view and pass reduce=false for find and count with reduce
        design_doc = db.get "_design/#{@design_document_name}" rescue nil
        db.save({
          "_id" => "_design/#{@design_document_name}",
            :views => {
              @view_name => {
                :map => @map_function,
                :reduce => @reduce_function
              }
            }
          }.merge(design_doc ? {'_rev' => design_doc['_rev']} : {}))
      end
      
      def db(name = nil)
        ::CouchPotato::Persistence.Db(name)
      end
      
      def query_view
        ::CouchPotato::Logger.debug "Sending query: #{view_url} with parameters: #{search_keys.inspect}"
        db.view view_url, search_keys
      end
      
      def view_url
        "#{@design_document_name}/#{@view_name}"
      end
      
      def search_keys
        if search_values.select{|v| v.is_a?(Range)}.any? || @order
          {:startkey => startkey, :endkey => endkey}.merge(view_options)
        elsif search_values.select{|v| v.is_a?(Array)}.any?
          {:keys => prepare_multi_key_search(search_values)}.merge(view_options)
        else
          view_options.merge(search_values.any? ? {:key => search_values} : {})
        end
      end
      
      def startkey
        search_values.map{|v| v.is_a?(Range) ? v.first : v}
      end
      
      def endkey
        search_values.map{|v| v.is_a?(Range) ? v.last : v || "\u9999"}
      end
      
      def search_values
        sorted_keys.map{|key| @conditions[key]}
      end
      
      def sorted_keys
        (@order || []) | @conditions.keys.sort{|x,y| x.to_s <=> y.to_s}
      end
      
      def view_options
        @view_options
      end
      
      def conditions
        @conditions
      end
      
      def prepare_multi_key_search(values)
        array = values.select{|v| v.is_a?(Array)}.first
        index = values.index array
        array.map do |item|
          copy = values.dup
          copy[index] = item
          copy
        end
      end
    end
  end
end