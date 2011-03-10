require 'csv_result'


class QueryResult
  include DataMapper::Resource
  
  property :id, Serial

  property :uuid, String

  property :statement, Text

  property :started_on, Time
  property :completed_on, Time
  property :elapsed_time, Float
  property :error, Text
  property :backtrace, Text

  property :number_of_rows, Integer
  property :number_of_bytes, Integer

  belongs_to :query_execution, :class_name => 'QueryExecution'
  property :query_results_index, Integer

  property :query_is_sensitive, Boolean
  property :result_is_sensitive, Boolean
 
  has_tags_on :tags


  def initialize opts
    super opts
    self.uuid ||= make_random_uuid
  end


  def make_random_uuid
    File.open('/proc/sys/kernel/random/uuid') do | fh |
      fh.readline.chomp!
    end
  end


  def self.base_dir
    @@base_dir ||=
      "query_result"
  end


  def filename
    @filename ||=
      "public#{uri}"
  end


  def file_mime_type file = filename
    'text/csv'.freeze
  end


  def uri
    @uri ||=
      "/#{self.class.base_dir}/#{uuid}.csv"
  end


  def execute!
    self.started_on = Time.now
    self.save!

    columns, types, rows = SqlHelper.sql_query(nil, self.statement)

    r = csv_result

    i = -1
    columns.each do | c |
      t = types[i += 1]
      csv_result.add_column(c, t)
    end

    csv_result.do_rows do | t |
      rows.each do | r |
        t.add_row r
      end
    end

    self.number_of_rows = rows.size + 2
    self.number_of_bytes = nil

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


  before :save do
    self.query_is_sensitive  ||= false
    self.result_is_sensitive ||= false
    if File.exist?(filename)
      self.number_of_rows  ||= csv_result.number_of_rows
      self.number_of_bytes ||= File.size(filename)
    end
  end

  after :save do
    close
  end

  after :destroy do
    csv_result.delete! if csv_result.exist?
  end
end

