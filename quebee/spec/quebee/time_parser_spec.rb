require 'quebee/time_parser'

describe Quebee::TimeParser do
  describe 'examples' do
    examples = Quebee::TimeParser.examples
    now = examples[:now]
    examples.each do | expr, val |
      next if Symbol === expr
      it "should translate #{expr.inspect} to #{val.inspect}" do
        tp = Quebee::TimeParser.new
        tp.now = now
        t = tp.parse(expr)
        t.to_s.should == val
      end
    end
  end
end
