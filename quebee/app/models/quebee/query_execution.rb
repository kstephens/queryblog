module Quebee

class QueryExecution
  include DataMapper::Resource
  include Auth::Tracking

  belongs_to :aborted_by, :child_key => [ :aborted_by_user_id ], :model => 'User'
  property :aborted_on, Time

  property :started_on, Time
  property :completed_on, Time
  property :elapsed_time, Float

  property :error, Text
  property :backtrace, Text

  belongs_to :query, :model => 'Query'
  property :query_executions_index, Integer

  has 0 .. n, :query_results, :model => 'QueryResult', :order => [ :query_results_index ]
  property :query_results_count, Integer

  property :query_is_sensitive, Boolean
  property :result_is_sensitive, Boolean
 
  has_tags_on :tags


  before :save do
    self.query_is_sensitive ||= false
    self.result_is_sensitive ||= false
    self.query_results_count ||= 0
  end


  def split_statements query = query.query
    statements = query.split(/\s*^\s*;;\s*$\s*/m)
    statements = statements.map { | x | x.sub(/\s*;\s*\Z/, '') + ';' }
  end


  def execute! opts = { }
    return false if self.aborted_by
    self.started_on = Time.now
    self.save!

    split_statements.each do | statement |
      index = self.query_results_count += 1
      self.save!

      qr = QueryResult.
        new(
            :statement => statement, 
            :query_execution => self, 
            :query_results_index => index,
            :query_is_sensitive => self.query_is_sensitive,
            :result_is_sensitive => self.result_is_sensitive
            )
      qr.execute!
    end

  rescue Exception => err
    self.error = err.inspect
    self.backtrace = err.backtrace * "\n"
    $stderr.puts "ERROR\n#{err.inspect}\n  #{err.backtrace * "\n  "}"

  ensure
    self.completed_on = Time.now
    self.elapsed_time = self.completed_on.to_f - self.started_on.to_f
    self.save!
  end

  def abort! user = Auth::Tracking.authenticated_user
    self.aborted_by = user
    self.save!
  end
end

end
