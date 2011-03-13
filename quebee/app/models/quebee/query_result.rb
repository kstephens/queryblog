require 'quebee/csv_result'

module Quebee

class QueryResult
  include DataMapper::Resource
  include Auth::Tracking

  property :uuid, String, :required => true

  property :statement, Text, :required => true
  property :explanation, Text

  property :started_on, Time, :required => true
  property :completed_on, Time
  property :elapsed_time, Float

  property :error, Text
  property :backtrace, Text

  property :number_of_rows, Integer
  property :number_of_bytes, Integer

  belongs_to :query_execution, :model => 'QueryExecution'
  property :query_results_index, Integer, :required => true

  property :query_is_sensitive, Boolean, :required => true
  property :result_is_sensitive, Boolean, :required => true
 
  has_tags_on :tags


  def initialize opts
    super opts
    self.uuid ||= make_random_uuid
  end


  UUID_FILE = '/proc/sys/kernel/random/uuid'.freeze
  @@uuid = nil

  def make_random_uuid
    if File.exist?(file = UUID_FILE)
      File.read(file).chomp!
    else
      unless @uuid
        require 'uuid'
        @@uuid = UUID.new
      end
      @@uuid.generate
    end
  end


  def self.base_dir
    @@base_dir ||=
      "quebee/query_result".freeze
  end


  def filename
    @filename ||=
      "public#{uri}".freeze
  end


  def file_mime_type file = filename
    'text/csv'.freeze
  end


  def uri
    @uri ||=
      "/#{self.class.base_dir}/#{uuid}.csv".freeze
  end


  def execute!
    # self.class.raise_on_save_failure = true
    self.created_by ||= query_execution.created_by

    # EXPLAIN query.
    columns, types, rows = Auth::SqlHelper.sql_query(nil, "EXPLAIN #{self.statement}")
    self.explanation = rows * "\n"
    self.started_on = Time.now
    self.save!
    debugger if self.id == nil

    # Run query.
    columns, types, rows = Auth::SqlHelper.sql_query(nil, self.statement)

    r = csv_result

    i = -1
    columns.each do | c |
      t = types[i += 1]
      # $stderr.puts "  i = #{i}: c = #{c.inspect} t = #{t.inspect}"
      csv_result.add_column(c, t)
    end

    csv_result.do_rows do | t |
      rows.each do | r |
        t.add_row r
      end
    end

    self.number_of_rows = rows.size + 2
    self.number_of_bytes = nil

    self

  rescue Exception => err
    self.error = err.inspect
    self.backtrace = err.backtrace * "\n"
    $stderr.puts "ERROR\n#{err.inspect}\n  #{err.backtrace * "\n  "}"
    raise err

  ensure
    self.completed_on = Time.now
    self.elapsed_time = self.completed_on.to_f - self.started_on.to_f
    self.save!
  end


  def csv_result
    @csv_result ||=
      CsvResult.new(:filename => filename)
  end


  def columns
    @columns ||=
      csv_result.exist? ? csv_result.columns : [ ]
  end


  def column_by_name
    @column_by_name ||=
      csv_result.exist? ? csv_result.column_by_name : { }
  end


  def [](i)
    csv_result.exist? ? csv_result[i] : nil
  end


  def size
    (number_of_rows - 2 rescue nil) || 0
  end


  def close
    if @csv_result
      @csv_result.close
      @csv_result = nil
    end
  end


  before :valid? do
    self.query_is_sensitive  ||= false
    self.result_is_sensitive ||= false
    if File.exist?(filename)
      self.number_of_rows  ||= csv_result.number_of_rows
      self.number_of_bytes ||= File.size(filename)
    end
    self
  end

  after :save do
    close
  end

  after :destroy do
    csv_result.delete! if csv_result.exist?
  end
end

end
