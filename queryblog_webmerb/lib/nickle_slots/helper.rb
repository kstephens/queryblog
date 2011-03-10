
module NickleSlots
  module Helper

    # Begins a new NickleSlots object.
    #
    # In user.html.erb:
    #
    #   <h1>User <%=h @user.name %></h1>
    #   <%= object :user, @user do %>
    #     <% slot :name %>
    #     <% slot :password, :type => :password %>
    #     <% slot :email %>
    #   <% end %>
    def object *args
      Builder.new.as_current do | b |
        b.object *args do
          yield
        end
      end
    end
    
    def slot *args
      Builder.current.slot *args
      EMPTY_STRING
    end

  end # module

end # module


module Merb::TagHelper
  include NickleSlots::Helper
end



