require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a query_execution exists" do
  QueryExecution.all.destroy!
  request(resource(:query_executions), :method => "POST", 
    :params => { :query_execution => { :id => nil }})
end

describe "resource(:query_executions)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:query_executions))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of query_executions" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a query_execution exists" do
    before(:each) do
      @response = request(resource(:query_executions))
    end
    
    it "has a list of query_executions" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      QueryExecution.all.destroy!
      @response = request(resource(:query_executions), :method => "POST", 
        :params => { :query_execution => { :id => nil }})
    end
    
    it "redirects to resource(:query_executions)" do
      @response.should redirect_to(resource(Query_execution.first), :message => {:notice => "query_execution was successfully created"})
    end
    
  end
end

describe "resource(@query_execution)" do 
  describe "a successful DELETE", :given => "a query_execution exists" do
     before(:each) do
       @response = request(resource(QueryExecution.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:query_executions))
     end

   end
end

describe "resource(:query_executions, :new)" do
  before(:each) do
    @response = request(resource(:query_executions, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@query_execution, :edit)", :given => "a query_execution exists" do
  before(:each) do
    @response = request(resource(QueryExecution.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@query_execution)", :given => "a query_execution exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(QueryExecution.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @query_execution = QueryExecution.first
      @response = request(resource(@query_execution), :method => "PUT", 
        :params => { :article => {:id => @query_execution.id} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@query_execution))
    end
  end
  
end

