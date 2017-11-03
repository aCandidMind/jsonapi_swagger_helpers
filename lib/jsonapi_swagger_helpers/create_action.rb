module JsonapiSwaggerHelpers
  class CreateAction
    include JsonapiSwaggerHelpers::Writeable

    def generate
      _self = self

      define_schema
      @node.operation :post do
        key :description, _self.description
        key :operationId, _self.operation_id
        key :tags, _self.all_tags

        if _self.strong_resource_action
          _self.util.id_in_url(self)
        end

        parameter do
          key :name, :payload
          key :in, :body
          schema do
            key :'$ref', _self.request_schema_id
            request_example = _self.example[:request]
            if request_example
              key :example, request_example
            end
          end
        end

        response 200 do
          key :example, _self.example[:response]
        end
      end
    end
  end
end
