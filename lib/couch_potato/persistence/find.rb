module CouchPotato
  module Persistence
    module Find
      def first(options = {}, view_options = {})
        Finder.new.find(self, options, view_options).first
      end
      
      def last(options = {}, view_options = {})
        Finder.new.find(self, options, view_options.merge(:descending => true)).first
      end
      
      def all(options = {}, view_options = {})
        Finder.new.find(self, options, view_options)
      end
      
      def count(options = {})
        Finder.new.count(self, options)
      end
    end
  end
end