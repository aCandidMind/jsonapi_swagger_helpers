module JsonapiSwaggerHelpers
  module Readable
    def self.included(klass)
      klass.class_eval do
        attr_reader :name,
          :node,
          :controller,
          :resource,
          :description,
          :tags,
          :example
      end
    end

    def initialize(name, node, controller, is_resource: true, description: nil, tags: [], example: nil)
      @name = name
      @node = node
      @controller = controller
      @is_resource = is_resource
      @resource = controller._jsonapi_compliable
      @description = description || default_description
      @tags = tags
      @example = example || {}
    end

    def action_name
      @name
    end

    def default_description
      "#{action_name.capitalize} Action"
    end

    def operation_id
      "#{controller.name.gsub('::', '-')}-#{action_name}"
    end

    def util
      JsonapiSwaggerHelpers::Util
    end

    def include_directive
      @is_resource ? util.include_directive_for(controller, action_name) : {}
    end

    def has_sideloads?
      @is_resource && include_directive.keys.length > 0
    end

    def has_extra_fields?
      @is_resource && resource.config[:extra_fields].keys.length > 1
    end

    def full_description
      full_desc = description
      if has_sideloads?
        full_desc = "#{full_desc}<br /><br />#{util.sideload_label(include_directive)}"
      end
      full_desc
    end

    def all_tags
      tags
    end

    def payload_tags
      util.payload_tags_for(resource, include_directive.to_hash)
    end

    def payloads
      util.payloads_for(resource, include_directive.to_hash)
    end

    def operation_id
      "#{controller._jsonapi_compliable.config[:model].name.demodulize}-#{action_name}"
    end

    def each_stat
      unless @is_resource
        return [].to_enum
      end
      resource.config[:stats].each_pair do |stat_name, opts|
        calculations = opts.calculations.keys - [:keys]
        calculations = calculations.join(', ')

        yield stat_name, calculations
      end
    end

    def each_association
      unless @is_resource
        return [].to_enum
      end
      types = [jsonapi_type]
      resource_map = util.all_resources(resource, include_directive)
      resource_map.each_pair do |association_name, association_resource|
        resource_type = association_resource.config[:type]
        next if types.include?(resource_type)
        types << resource_type
        yield association_name, association_resource
      end
    end

    def jsonapi_type
      resource.config[:type]
    end

    def response_schema_id
      "#{operation_id}_response"
    end

    def generate_response_schema!
      _self = self

      JsonapiSwaggerHelpers.docs_controller.send(:swagger_schema, response_schema_id) do
        _self.payloads.each do |p|
          property p.name do
            key :'$ref', p.name
          end
        end
      end
    end

    def generate
      raise 'override me'
    end
  end
end
