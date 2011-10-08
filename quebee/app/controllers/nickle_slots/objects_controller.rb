require 'pp' # see get.html.erb
require 'json'
require 'json/add/core'
require 'json/add/rails'

module NickleSlots

# Provides a generic authenticated Ajax slot getter/setter controller.
class ObjectsController < ApplicationController # AuthenticatedController
  respond_to :html, :xml, :json # , :txt
  # ::Mime::TXT = ::Mime['txt'] # UGLY!

  layout false

  def get
    load_obj
    if @slot
      @value = @obj.send(@slot)
    else
      @value = @obj
    end
    render_value
  end

  def set
    load_obj
    if @slot 
      converter = :"#{@slot}_from_param"
      @value = params[:value]
      @value = @obj.send(converter, @value) if @obj.respond_to?(converter)
      @obj.send(:"#{@slot}=", @value)
      @value = @obj.send(@slot)
    else
      raise ArgumentError, "no slot parameter"
    end
    render_value
  end

private

  def load_obj
    $stderr.puts "params = #{params.inspect}"
    @clsname = params[:cls] or raise ArgumentError, "no cls parameter"
    @id      = params[:id] or raise ArgumentError, "no id parameter"
    @slot    = params[:slot] # or raise ArgumentError, "no slot parameter"
    @slot &&= @slot.to_sym
    # raise ArgumentError, "protected attribute" if @slot == :attributes
    @cls = (@clsname.split('::').inject(Object){ | o, n | o.const_get(n) } rescue nil)
    raise ArgumentError, "Cannot locate class #{@clsname.inspect}" unless @cls
    @obj = @cls.get!(@id)
  end

  def render_value
    if @slot
      converter = :"#{@slot}_to_param"
      @value = @obj.send(converter, @value) if @obj.respond_to?(converter)
    else
      @value = @obj
    end
    format = (params[:format] || :html).to_sym
    case format
    when :html
    when :xml
      @value = wrap_to_xml(@value).to_xml
    when :json
      @value = @value.to_json
      # @value = wrap_encode_json(@value).encode_json
    when :txt
      @value = PP.pp(@value, '')
    end
    render :text => @value, :content_encoding => ::Mime[format]
  end

  def wrap_to_xml value
    unless value.respond_to?(:to_xml)
      value = AsXml.new(value)
    end
    value
  end
  class AsXml
    def initialize value
      @value = value
    end
    def to_xml value = @value
      case value
      when true, false, nil, Numeric, String, Symbol
        "<#{value.class}>#{value.inspect}</#{value.class}"
      when
        tag = value.class.name.gsub('::', '.')
        case value
        when Array
          out = "<#{tag}>"
          value.each { | e | out << to_xml(e) }
          out << "</#{tag}>"
        when Hash
        else
          "<#{tag}>#{PP.pp(value, '')}</#{tag}>"
        end
      end
    end
  end

  def wrap_encode_json value
    unless value.respond_to?(:encode_json)
      value = AsJson.new(value)
    end
    value
  end
  class AsJson
    def initialize value
      @value = value
    end
    def encode_json
      @value.to_json
    end
  end

  def authorizer
    @authorizer ||=
      Authorizer.new(:user => current_user)
  end

  def self.route! r
    r.instance_eval do
      match 'ns/object/(/:cls(/:id(/:slot)(.:format)))' => 'nickle_slots/objects#get'
    end
  end

end # ObjectsController

end
