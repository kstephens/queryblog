require 'fileutils'
require 'csv'

module Quebee

# Represents a basic CSV file.
# with a row_index file for fast pagination.
class CsvResult
  # Generic error.
  class Error < ::Exception; end

  attr_accessor :filename
  attr_accessor :number_of_rows
  attr_accessor :number_of_bytes


  def initialize opts
    @columns = nil
    @column_names = nil
    @column_by_name = nil
    @filename = opts[:filename]
    @row_index = nil
  end


  def filename_row_index
    "#{filename}.row_index"
  end


  def exist?
    (@exist ||= [
                 File.exist?(filename) &&
                 File.exist?(filename_row_index)
                ]).first
  end


  # Returns a RowIndex for this file.
  def row_index
    @row_index ||= 
      RowIndex.new(:filename => filename_row_index)
  end


  # Add a column with a type.
  def add_column name, type = nil
    type ||= 'String'
    type = type.name if Module === type

    @columns ||= [ ]
    @column_by_name ||= { }

    c = Column.new(:name => name, :type => type, :index => @columns.size)

    @columns << c 
    @column_by_name[c.name] = c

    c
  end


  def row_file
    @row_file ||= 
      begin
        FileUtils.mkdir_p(File.dirname(filename))
        File.open(filename, "r")
      end
  end


  def do_rows
    raise ArgumentError unless block_given?
    begin_rows
    yield self
  ensure
    end_rows
    close
  end


  # Start the 
  def begin_rows
    raise Error, "no columns defined" if @columns == nil || @columns.size == 0

    File.unlink(filename) rescue nil
    @row_file = File.open(filename, 'a+')
    @row_file.seek(0)

    @row_index = nil
    @number_of_rows = 0

    # row_index.number_of_rows = 0

    # Write the column name row.
    _write_row(@columns.map { | c | c.name })

    # Write the column type row.
    _write_row(@columns.map { | c | c.type.name })
  end


  def add_row row
    case row
    when Hash
      row = @columns.map { | c | row[c.name] }
    when Array
    when nil
      row = @columns.map { | c | nil }
    else
      raise ArgumentError
    end

    _write_row row
  end
  alias :<< :add_row


  def _write_row row
    row_index[@number_of_rows] = @row_file.tell
    $stderr.puts "  _write_row(#{row.inspect}) @ #{@row_file.tell}" if @verbose
    @row_file.write(row.to_csv)
    @number_of_rows += 1
  end


  def end_rows
    @row_file.close if @row_file
    @row_file = nil
    UniqueFile.link_to_unique_file!(filename)

    row_index.number_of_rows = @number_of_rows
    row_index.close
    UniqueFile.link_to_unique_file!(filename_row_index)
  end


  def columns
    unless @columns
      lines = nil
      
      File.open(filename, 'r') do | fh |
        lines = fh.readline + fh.readline
      end
      
      lines = CSV.parse(lines)
      column_names = lines[0]
      column_types = lines[1]
      
      i = -1
      @column_by_name = { }
      @columns = column_names.map do | n |
        i += 1
        c = Column.new(:name => n, :type => column_types[i], :index => i)
        @column_by_name[c.name] = c
      end
    end
    @columns
  end


  def column_by_name
    columns
    @column_by_name
  end


  def column_names
    @column_names ||= 
      columns.map { | c | c.name_sym }
  end


  # Returns the number of rows in the CSV file,
  # including the column name and column type header rows.
  def number_of_rows
    @number_of_rows ||=
      row_index.number_of_rows
  end


  def number_of_rows= x
    if @number_of_rows != x
      @number_of_rows = x
      row_index.number_of_rows = x
    end
    x
  end


  def size
    number_of_rows - 2
  end


  # Reads a row from the CSV file.
  def [](i)
    hash = nil
    pos = row_index[i + 2]
    File.open(filename, 'r') do | fh |
      fh.seek(pos)
      row = CSV.parse_line(fh)
      hash = _row_to_hash row
    end
    close
    hash
  end


  def each 
    (0 ... size).each do | i |
      yield self[i]
    end
  end


  def _row_to_hash row
    Hash[*column_names.zip(row).flatten]
  end
 

  # Returns all rows
  def rows
    @rows ||= 
      begin
        rows = CSV.read(filename)
        $stderr.puts "rows = #{rows.inspect}"
        rows.shift
        rows.shift
        rows.map! do | r |
          _row_to_hash r
        end
        rows
      end
  end


  # Closes any open files.
  def close
    @row_file.close if @row_file
    @row_file = nil
    @row_index.close if @row_index
  end


  def delete!
    File.unlink(filename) rescue nil
    File.unlink("#{filename}.symlink") rescue nil
    File.unlink(filename_row_index) rescue nil
    File.unlink("#{filename_row_index}.symlink") rescue nil
  end


  # Represents a absic column, with a type and column index.
  class Column
    attr_accessor :name
    attr_reader   :name_sym
    attr_accessor :type
    attr_accessor :index

    def initialize opts
      @name_sym = opts[:name].to_sym
      @name = @name_sym.freeze
      @type = Type.coerce(opts[:type])
      @index = opts[:index]
    end

    def inspect
      "#<#{self.class} #{@name.inspect} #{type.inspect} at #{@index}>"
    end

  end


  # Represents a basic column type.
  class Type
    attr_accessor :name

    @@instance_cache = { }

    def self.coerce name
      case name
      when self, nil
        name
      when String, Symbol
        name = name.to_s
        @@instance_cache[name] ||
          Type.new(:name => name)
      else
        raise ArgumentError, "given #{name.class}"
      end
    end

    def initialize opts
      @name = opts[:name].dup.freeze
    end

    def inspect
      "#<#{self.class} #{@name.inspect}>"
    end
  end


  # Manages an simple file position index for rows in a CSV file.
  # First line contains the number of rows in the CSV file.
  class RowIndex
    attr_accessor :filename

    def initialize opts
      @filename = opts[:filename]
      @rows = [ ]
    end


    def number_of_rows
      @number_of_rows ||=
        _read_at(0)
    end


    def number_of_rows= x
      if @number_of_rows != x
        if x
          close
          write_file.seek(0, IO::SEEK_SET)
          _write_at(0, x)
          close
        end
        @number_of_rows = x
      end
      x
    end


    def size
      number_of_rows
    end


    def [](i)
      raise ArgumentError if i < 0
      _read_at(i + 1)
    end


    def []=(i, v)
      raise ArgumentError if i < 0
      _write_at(i + 1, v)
    end


    def _read_at i
      @rows[i] ||=
        begin
          f = read_file
          f.seek(pos = i * 17)
          line = f.read(16) rescue nil
          return 0 unless line
          v = line.hex
          # $stderr.puts "  _read_at(#{i}) => (pos = #{pos}, v = #{v})"
          v
        end
    end


    def _write_at i, v
      unless @rows[i] == v
        @rows[i] = v
        f = write_file
        f.seek(pos = i * 17)
        f.write(str = "%016x\n" % v.to_i)
        # @read_file.seek(0, IO::SEEK_END) if @read_file
        # $stderr.puts "  _write_at(#{i}, #{v}) => (pos = #{pos})"
        v
      end
      v
    end


    def read_file
      @read_file ||=
        begin
          @rows ||= [ ]
          FileUtils.mkdir_p(File.dirname(filename))
          fh = File.open(filename, 'r')
          fh.binmode
          fh.sync = true
          fh.seek(0, IO::SEEK_SET)
          fh
         end
    end

    def write_file
      @write_file ||=
        begin
          @rows ||= [ ]
          FileUtils.mkdir_p(File.dirname(filename))
          write_initial = ! File.exists?(filename)
          fh = File.open(filename, 'a')
          fh.binmode
          fh.sync = true
          fh.seek(0, IO::SEEK_END)
          if write_initial
            _write_at(0, 0)
          end
          fh
        end
    end


    def close
      if @read_file
        @read_file.seek(0, IO::SEEK_END)
        @read_file.close
        @read_file = nil
      end
      if @write_file
        @write_file.seek(0, IO::SEEK_END)
        @write_file.close
        @write_file = nil
      end
      @rows = [ ]
    end


    def delete!
      if @filename && File.exist?(@filename)
        File.unlink(@filename)
        File.unlink("#{@filename}.symlink") rescue nil
      end
    end
  end


  def self.test
    filename = "foo"

    x = CsvResult.new(:filename => filename)
    x.add_column(:name, 'CHAR(16)')
    x.add_column(:user, 'CHAR(16)')
    x.do_rows do | x |
      x << [ 'kurt', 'kstephens' ]
      x << { :name => 'joe', :user => 'juser' }
    end

    x = CsvResult.new(:filename => filename)
    puts x.columns.inspect
    puts x.number_of_rows.inspect
    puts x[0].inspect
    puts x[1].inspect

    puts x.rows.inspect
  end

end # class


module UniqueFile

  def self.link_to_unique_file! file
    return unless File.exists? file
    file_symlink = "#{file}.symlink"
    unless File.symlink?(file_symlink)
      $stderr.puts "  #{file_symlink.inspect}  is not a symlink"

      hash = file_hash(file)
      $stderr.puts "  #{file.inspect} hash is #{hash.inspect}"

      file_hash = "#{File.dirname(file)}/#{hash}"
      if File.exist?(file_hash)
        $stderr.puts "  #{file_hash.inspect} exists"
        File.unlink(file)
      else
        $stderr.puts "  #{file_hash.inspect} does not exist"
        File.rename(file, file_hash)
      end
      File.chmod(0444, file_hash) rescue nil

      $stderr.puts "  ln #{file_hash.inspect} #{file.inspect}"
      File.link(file_hash, file)

      $stderr.puts "  ln -ns #{file_hash.inspect} #{file_symlink.inspect}"
      File.symlink(File.basename(file_hash), file_symlink)
    end
  end

  def self.file_hash file
    d = Digest::MD5.new
    File.open(file) do | fh |
      d << (fh.read(8192) || "")
    end
    d.hexdigest
  end

end

end
