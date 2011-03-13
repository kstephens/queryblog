

module Kernel
  def require_with_trace *args
    $stderr.puts "  require #{args.inspect} from #{caller[0]}"
    require_without_trace *args
  end
  alias :require_without_trace :require
  alias :require :require_with_trace

  def load_with_trace *args
    $stderr.puts "  load #{args.inspect} from #{caller[0]}"
    load_without_trace *args
  end
  alias :load_without_trace :load
  alias :load :load_with_trace
end

