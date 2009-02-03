require 'rubygems'
require 'active_support'
require 'json'
require 'json/add/core'
require 'json/add/rails'

require 'ostruct'

module CouchPotato
  class SimpleLogger
    def debug(message)
      $stderr.puts message
    end
  end
  
  Config = OpenStruct.new
  Logger = SimpleLogger.new
end

require File.dirname(__FILE__) + '/core_ext/object'
require File.dirname(__FILE__) + '/core_ext/time'

require File.dirname(__FILE__) + '/couch_potato/persistence'
require File.dirname(__FILE__) + '/couch_potato/versioning'
require File.dirname(__FILE__) + '/couch_potato/ordering'
require File.dirname(__FILE__) + '/couch_potato/active_record/compatibility'

