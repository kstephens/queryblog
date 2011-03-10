require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Query, "index action" do
  before(:each) do
    dispatch_to(Query, :index)
  end
end