module JsonapiSwaggerHelpers
  class UpdateAction
    include JsonapiSwaggerHelpers::Writeable

    def generate
      _self = self

      define_schema
      @node.operation :put do
        key :description, _self.description
        key :operationId, _self.operation_id
        key :tags, _self.all_tags

        _self.util.id_in_url(self)

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
