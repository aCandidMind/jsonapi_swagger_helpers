module JsonapiSwaggerHelpers
  class ShowAction
    include JsonapiSwaggerHelpers::Readable

    def generate
      _self = self
      _is_resource = @is_resource
      generate_response_schema!

      @node.operation :get do
        key :description, _self.full_description
        key :operationId, _self.operation_id
        key :tags, _self.all_tags

        request_example = _self.example[:request]
        if request_example
          key :'x-code-samples', [{lang: 'http', source: request_example}]
        end

        response 200 do
          schema do
            key :'$ref', _self.response_schema_id
          end
          key :example, _self.example[:response]
        end

        _self.util.id_in_url(self)
        if _is_resource
          _self.util.jsonapi_fields(self, _self.jsonapi_type)
        end

        if _self.has_extra_fields?
          _self.util.jsonapi_extra_fields(self, _self.resource)
        end

        _self.each_stat do |stat_name, calculations|
          _self.util.jsonapi_stat(self, stat_name, calculations)
        end

        if _self.has_sideloads?
          includes = _self.include_directive.to_string.split(",").sort.join(",<br/>")
          _self.util.jsonapi_includes(self, includes)

          _self.each_association do |association_name, association_resource|
            _self.util.jsonapi_fields(self, association_resource.config[:type])

            if association_resource.config[:extra_fields].keys.length > 0
              _self.util.jsonapi_extra_fields(self, association_resource)
            end

            _self.util.each_filter(association_resource, association_name) do |filter_label|
              _self.util.jsonapi_filter(self, filter_label)
            end
          end
        end
      end
    end
  end
end
