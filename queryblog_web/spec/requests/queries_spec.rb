require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a query exists" do
  Query.all.destroy!
  request(resource(:queries), :method => "POST", 
    :params => { :query => { :id => nil }})
end

describe "resource(:queries)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:queries))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of queries" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a query exists" do
    before(:each) do
      @response = request(resource(:queries))
    end
    
    it "has a list of queries" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      Query.all.destroy!
      @response = request(resource(:queries), :method => "POST", 
        :params => { :query => { :id => nil }})
    end
    
    it "redirects to resource(:queries)" do
      @response.should redirect_to(resource(Query.first), :message => {:notice => "query was successfully created"})
    end
    
  end
end

describe "resource(@query)" do 
  describe "a successful DELETE", :given => "a query exists" do
     before(:each) do
       @response = request(resource(Query.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:queries))
     end

   end
end

describe "resource(:queries, :new)" do
  before(:each) do
    @response = request(resource(:queries, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@query, :edit)", :given => "a query exists" do
  before(:each) do
    @response = request(resource(Query.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@query)", :given => "a query exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Query.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @query = Query.first
      @response = request(resource(@query), :method => "PUT", 
        :params => { :article => {:id => @query.id} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@query))
    end
  end
  
end

