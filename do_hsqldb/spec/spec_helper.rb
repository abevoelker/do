$TESTING=true
JRUBY = true

require 'rubygems'
require 'bacon'

require 'date'
require 'ostruct'
require 'pathname'
require 'fileutils'

dir = File.dirname(__FILE__)
lib_path = File.expand_path("#{dir}/../lib")
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)
# put data_objects from repository in the load path
# DO NOT USE installed gem of data_objects!
do_lib_path = File.expand_path("#{dir}/../../data_objects/lib")
$LOAD_PATH.unshift do_lib_path unless $LOAD_PATH.include?(do_lib_path)

if JRUBY
  jdbc_lib_path = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'do_jdbc', 'lib'))
  $LOAD_PATH.unshift jdbc_lib_path unless $LOAD_PATH.include?(jdbc_lib_path)
  require 'do_jdbc'
end

require 'data_objects'

DATAOBJECTS_SPEC_ROOT = Pathname(__FILE__).dirname.parent.parent + 'data_objects' + 'spec'
Pathname.glob((DATAOBJECTS_SPEC_ROOT + 'lib/**/*.rb').to_s).each { |f| require f }

require 'do_hsqldb'

log_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'log', 'do.log'))
FileUtils.mkdir_p(File.dirname(log_path))

DataObjects::Hsqldb.logger = DataObjects::Logger.new(log_path, :debug)

at_exit { DataObjects.logger.flush }

Bacon.summary_on_exit

CONFIG = OpenStruct.new
# CONFIG.scheme   = 'hsqldb'
# CONFIG.user     = ENV['DO_HSQLDB_USER'] || 'hsqldb'
# CONFIG.pass     = ENV['DO_HSQLDB_PASS'] || ''
# CONFIG.host     = ENV['DO_HSQLDB_HOST'] || ''
# CONFIG.port     = ENV['DO_HSQLDB_PORT'] || ''
# CONFIG.database = ENV['DO_HSQLDB_DATABASE'] || "#{File.expand_path(File.dirname(__FILE__))}/testdb"

CONFIG.uri = ENV["DO_HSQLDB_SPEC_URI"] || "jdbc:hsqldb:mem:test"

module DataObjectsSpecHelpers

  def setup_test_environment
    conn = DataObjects::Connection.new(CONFIG.uri)

    conn.create_command(<<-EOF).execute_non_query
      DROP TABLE IF EXISTS invoices
    EOF

    conn.create_command(<<-EOF).execute_non_query
      DROP TABLE IF EXISTS users
    EOF

    conn.create_command(<<-EOF).execute_non_query
      DROP TABLE IF EXISTS widgets
    EOF

    conn.create_command(<<-EOF).execute_non_query
      CREATE TABLE users (
        id                INTEGER GENERATED BY DEFAULT AS IDENTITY(START WITH 1),
        name              VARCHAR(200) default 'Billy' NULL,
        fired_at          TIMESTAMP
      )
    EOF

    conn.create_command(<<-EOF).execute_non_query
      CREATE TABLE invoices (
        id                INTEGER IDENTITY,
        invoice_number    VARCHAR(50) NOT NULL
      )
    EOF

    conn.create_command(<<-EOF).execute_non_query
      CREATE TABLE widgets (
        id                INTEGER IDENTITY,
        code              CHAR(8) DEFAULT 'A14' NULL,
        name              VARCHAR(200) DEFAULT 'Super Widget' NULL,
        shelf_location    VARCHAR NULL,
        description       LONGVARCHAR NULL,
        image_data        VARBINARY NULL,
        ad_description    LONGVARCHAR NULL,
        ad_image          VARBINARY NULL,
        whitepaper_text   LONGVARCHAR NULL,
        cad_drawing       LONGVARBINARY NULL,
        flags             BOOLEAN DEFAULT 0,
        number_in_stock   SMALLINT DEFAULT 500,
        number_sold       INTEGER DEFAULT 0,
        super_number      BIGINT DEFAULT 9223372036854775807,
        weight            FLOAT DEFAULT 1.23,
        cost1             REAL DEFAULT 10.23,
        cost2             DECIMAL DEFAULT 50.23,
        release_date      DATE DEFAULT '2008-02-14',
        release_datetime  DATETIME DEFAULT '2008-02-14 00:31:12',
        release_timestamp TIMESTAMP DEFAULT '2008-02-14 00:31:31'
      )
    EOF
    # XXX: HSQLDB has no ENUM
    # status` enum('active','out of stock') NOT NULL default 'active'

    1.upto(16) do |n|
      conn.create_command(<<-EOF).execute_non_query
        INSERT INTO widgets(
          code,
          name,
          shelf_location,
          description,
          image_data,
          ad_description,
          ad_image,
          whitepaper_text,
          cad_drawing,
          super_number,
          weight)
        VALUES (
          'W#{n.to_s.rjust(7,"0")}',
          'Widget #{n}',
          'A14',
          'This is a description',
          '4f3d4331434343434331',
          'Buy this product now!',
          '4f3d4331434343434331',
          'String',
          '4f3d4331434343434331',
          1234,
          13.4);
      EOF

      conn.create_command(<<-EOF).execute_non_query
        update widgets set flags = true where id = 2
      EOF

      conn.create_command(<<-EOF).execute_non_query
        update widgets set ad_description = NULL where id = 3
      EOF

      conn.create_command(<<-EOF).execute_non_query
        update widgets set flags = NULL where id = 4
      EOF

      conn.create_command(<<-EOF).execute_non_query
        update widgets set cost1 = NULL where id = 5
      EOF

      conn.create_command(<<-EOF).execute_non_query
        update widgets set cost2 = NULL where id = 6
      EOF

      conn.create_command(<<-EOF).execute_non_query
        update widgets set release_date = NULL where id = 7
      EOF

      conn.create_command(<<-EOF).execute_non_query
        update widgets set release_datetime = NULL where id = 8
      EOF

      conn.create_command(<<-EOF).execute_non_query
        update widgets set release_timestamp = NULL where id = 9
      EOF

      ## TODO: change the hexadecimal examples
      conn.close
    end

  end
end

include DataObjectsSpecHelpers
include DataObjects::Spec::PendingHelpers
