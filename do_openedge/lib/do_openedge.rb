require 'data_objects'

if RUBY_PLATFORM =~ /java/
  require 'do_jdbc'
  require 'java'
  require 'date' # Required for creating native Ruby Date and DateTimes

  begin
    java.lang.Thread.currentThread.getContextClassLoader().loadClass(DataObjects::Openedge::JDBC_DRIVER, true)
  rescue
    # Load the JDBC driver
    begin
      require 'openedge.jar'
      require 'pool.jar'
    rescue
      raise LoadError, "openedge.jar and pool.jar must be in your $CLASSPATH!"
    end
  end

  module DataObjects
    module Openedge
      JDBC_DRIVER = 'com.ddtek.jdbc.openedge.OpenEdgeDriver'
    end
  end

  require 'do_openedge/do_openedge'    # the Java extension for this DO driver

  # Another way of loading the JDBC Class. This seems to be more reliable
  # than Class.forName() within the data_objects.Connection Java class,
  # which is currently not working as expected.
  java_import DataObjects::Openedge::JDBC_DRIVER

else
  warn "do_openedge is only for use with JRuby"
end
