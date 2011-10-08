module Auth

module SqlHelper
  def self.sql_query(repos, sql, *params)
    result = [ ]
    columns = [ ]
    types = [ ]
    repos = repos.default_repository_name if Class === repos
    repos = repository(repos)
    repos.adapter.send(:with_connection) do |connection|
      $stderr.puts "connection = #{connection.class}"
      begin
        command = connection.create_command(sql)
        $stderr.puts "command = #{command.class}"
        reader = command.execute_reader(*params)
        $stderr.puts "reader = #{reader.class}"
        # $stderr.puts "reader = #{reader.inspect}"
        columns = reader.fields.dup
        types = reader.instance_variable_get(:@field_types).dup

        while reader.next!
          result << reader.values
        end
      ensure
        reader.close if reader
      end
    end
    # $stderr.puts "do_sql #{sql.split("\n").first} =>\n  #{result.map{|x| x.inspect}.join("\n  ")}"
    [ columns, types, result ]
  end
end

end
