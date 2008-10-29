require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a query_result exists" do
  QueryResult.all.destroy!
  request(resource(:query_results), :method => "POST", 
    :params => { :query_result => { :id => nil }})
end

describe "resource(:query_results)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:query_results))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of query_results" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a query_result exists" do
    before(:each) do
      @response = request(resource(:query_results))
    end
    
    it "has a list of query_results" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      QueryResult.all.destroy!
      @response = request(resource(:query_results), :method => "POST", 
        :params => { :query_result => { :id => nil }})
    end
    
    it "redirects to resource(:query_results)" do
      @response.should redirect_to(resource(Query_result.first), :message => {:notice => "query_result was successfully created"})
    end
    
  end
end

describe "resource(@query_result)" do 
  describe "a successful DELETE", :given => "a query_result exists" do
     before(:each) do
       @response = request(resource(QueryResult.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:query_results))
     end

   end
end

describe "resource(:query_results, :new)" do
  before(:each) do
    @response = request(resource(:query_results, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@query_result, :edit)", :given => "a query_result exists" do
  before(:each) do
    @response = request(resource(QueryResult.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@query_result)", :given => "a query_result exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(QueryResult.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @query_result = QueryResult.first
      @response = request(resource(@query_result), :method => "PUT", 
        :params => { :article => {:id => @query_result.id} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@query_result))
    end
  end
  
end

