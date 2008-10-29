require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe HomeController, "index action" do
  before(:each) do
    dispatch_to(HomeController, :index)
  end
end