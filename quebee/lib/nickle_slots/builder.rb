require 'multi_json'

module NickleSlots
class Builder
  def self.current
    Thread.current[:'NickleSlots::Builder']
  end


  def self.current= x
    Thread.current[:'NickleSlots::Builder'] = x
  end


  def as_current
    current_save = self.class.current
    self.class.current = self
    yield self
  ensure
    self.class.current = current_save
  end


  attr_accessor :parent
  attr_accessor :dom_id

  attr_accessor :authorizer

  attr_accessor :capture


  def initialize opts = EMPTY_HASH
    opts.each do | k , v |
      send("#{k}=", v)
    end
  end


  def authorizer
    @authorizer ||=
      Authorizer.instance
  end


  def object name, object = nil, opts = { }, &blk
    @parent ||= self.class.current
    @authorizer ||= @parent && @parent.authorizer
    object ||= parent.slot_value(name)
    @object = object
    @name = name || object.class.name
    @dom_id = name.to_s + '__' + object_id.to_s

    @capture = ''
    self.as_current do
      @capture << blk.call.to_s
    end
    object_begin + @capture + object_end
  end


  def object_begin
    tag :table
  end

  def object_end
    tag_end :table
  end


  # FIXME!
  def h x
    x.to_s
  end


  def titleize x
    x = x.to_s
    x = x.split('_')
    x.map do | x |
      x[0 .. 0].upcase + x[1 .. -1]
    end.join(' ')
  end


  def text x
    h(x)
  end


  def tag name, attrs = EMPTY_HASH
    out = '<'
    out << name.to_s
    attrs.each do | k, v |
      out << " #{k.to_s}=\"#{h v.to_s}\""
    end
    out << '>'
    if block_given?
      out << (yield).to_s
      out << tag_end(name)
    end

    out
  end


  @@tag_end ||= { }
  def tag_end name
    @@tag_end[name.to_sym] ||= "</#{name}>"
  end


  def slot_value name, opts = EMPTY_HASH
    @object && 
      @object.send(name)
  end


  def class_selector
    @class_selector ||=
      @object.class.name.downcase
  end


  def object_id
    @object_id ||=
      @object.id
  end


  def authorizer_selector name, action
    "#{class_selector}/#{action}/#{object_id}/#{name}" 
  end


  def ref name
    "object/#{class_selector}/#{object_id}/#{name}"
  end


  # Options:
  #
  #   :type => [ :input, :password, :textarea, :object ]
  #   :editable => [ true, false ]
  #   :readonly => [ true, false ]
  #   :label => String
  #   :class => String
  #   
  def slot name, opts = { }, &blk
    editable = true
    editable = opts.delete(:editable) if opts.key?(:editable)
    editable &&= ! opts.delete(:readonly)

    @capture <<
    case 
    when ! authorizer.allow?(authorizer_selector(name, :view))
      # do nothing
      EMPTY_STRING
    when editable && authorizer.allow?(authorizer_selector(name, :edit))
      opts[:editable] = true
      slot_ name, opts, &blk
    else
      slot_ name, opts, &blk
    end

    EMPTY_STRING
  end


  def slot_begin name, opts
    tag :tr, :class => :ns_slot
  end


  def slot_end(name, opts)
    tag_end :tr
  end


  def slot_label name, opts
    label = opts[:label] || titleize(name)
    tag(:th, :class => :ns_slot_label) do
      text label
    end
  end


  def slot_ name, opts = { }, &blk
    slot_begin(name, opts) +
    slot_label(name, opts) +
    tag(:td) do
      slot_element(name, opts, &blk) +
      "<script type=\"text/javascript\">\n" +
      "<!-- \n" +
        "NickleSlots.editable(#{MultiJson.generate(opts)});\n" + 
      " --> \n" +
      '</script>'
    end +
    slot_end(name, opts)
  end

  
  def slot_element name, opts_orig = { }
    opts = opts_orig.dup
    type = opts.delete(:type) || :input
    opts_orig[:type] = type

    editable = opts.delete(:editable)
    if editable
      opts[:class] += ' ' if opts[:class]
      opts[:class] ||= ''
      opts[:class] += 'ns_editable'
    end
    opts_orig[:class] = opts[:class]

    opts[:id] ||= dom_id + '__' + name.to_s
    opts_orig[:dom_id] = opts[:id]

    opts[:ref] = ref(name)

    value = slot_value(name)

    if func = opts.delete(:display_filter)
      value =
      case func.arity
      when 1
        func.call(value)
      else
        func.call(object, name, value)
      end
    end

    map_to_select = opts.delete(:map_to_select)

    case type
    when nil, :input
      tag(:span, opts) do 
        text value
      end

    when :boolean
      tag(:span, opts) do
        if map_to_select
          value =
          case map_to_selector.arity
          when 1
            map_to_selector.call(value)
          else
            map_to_selector.call(object, name, value)
          end
        else
          value = ! ! value ? 'True' : 'False'
        end 
        text(value)
      end

    when :password
      tag(:span, opts) do 
        text value.to_s.gsub(/./, '*')
      end

    when :textarea
      tag(:pre, opts) do
        text value
      end

    when :select
      tag(:span, opts) do
        if map_to_select
          value = map_to_selector.call(object, name, value)
        end
        text value
      end

    when :object
      self.class.new(:parent => self, :dom_id => opts[:dom_id] ).object(name, value, opts) do
        yield
      end

    else
      raise ArgumentError, "invalid type #{type.inspect}"
    end
  end



#=begin
  # Dummy Authorizer
  class Authorizer
    def self.instance
      @instance ||= new
    end
    
    def allow? *args
      true
    end
  end
#=end

end # class
end # builder


########################################################################



