module JsonapiSwaggerHelpers
  module ResourceMixin

    def jsonapi_resource(base_path,
                         prefix: nil,
                         tags: [],
                         descriptions: {},
                         only: [],
                         except: [],
                         action_mappings: {},
                         strong_resource_action: nil,
                         examples: {}
                        )
      self.resources << {
        base_path: base_path,
        prefix: prefix,
        tags: tags,
        descriptions: descriptions,
        only: only,
        except: except,
        action_mappings: action_mappings,
        strong_resource_action: strong_resource_action,
        examples: examples
      }
    end

    def load_resource(config)
      base_path = config[:base_path]
      prefix = config[:prefix]
      tags = config[:tags]
      descriptions = config[:descriptions]
      only = config[:only]
      except = config[:except]
      examples = config[:examples]
      action_mappings = config[:action_mappings]
      strong_resource_action = config[:strong_resource_action]

      actions = [:index, :show, :create, :update, :destroy]
      actions.select! { |a| only.include?(a) } unless only.empty?
      actions.reject! { |a| except.include?(a) } unless except.empty?

      prefix     = prefix || @swagger_root_node.data[:basePath]
      full_path  = [prefix, base_path].join('/').gsub('//', '/')
      controller = JsonapiSwaggerHelpers::Util.controller_for(full_path, action_mappings)

      base_path_for_swagger = base_path.gsub(/:(\w+)/, '{\1}')

      ctx = self
      if [:create, :index].any? { |a| actions.include?(a) }
        swagger_path base_path_for_swagger do
          if actions.include?(:index) && controller.action_methods.include?('index')
            index_action = JsonapiSwaggerHelpers::IndexAction.new \
              :index, self, controller, tags: tags, description: descriptions[:index], example: examples[:index]
            index_action.generate
          end

          if actions.include?(:create) && controller.action_methods.include?('create')
            create_action = JsonapiSwaggerHelpers::CreateAction.new \
              :create, self, controller, tags: tags, description: descriptions[:create], example: examples[:create]
            create_action.generate
          end
        end
      end

      if [:show, :update, :destroy].any? { |a| actions.include?(a) }
        ctx = self
        swagger_path "#{base_path_for_swagger}/{id}" do
          if actions.include?(:show) && controller.action_methods.include?('show')
            show_action = JsonapiSwaggerHelpers::ShowAction.new \
              :show,self, controller, tags: tags, description: descriptions[:show], example: examples[:show]
            show_action.generate
          end

          if actions.include?(:update) && controller.action_methods.include?('update')
            update_action = JsonapiSwaggerHelpers::UpdateAction.new \
              :update,self, controller, tags: tags, description: descriptions[:update], example: examples[:update]
            update_action.generate
          end

          if actions.include?(:destroy) && controller.action_methods.include?('destroy')
            destroy_action = JsonapiSwaggerHelpers::DestroyAction.new \
              :destroy, self, controller, tags: tags, description: descriptions[:destroy], example: examples[:destroy]
            destroy_action.generate
          end
        end
      end

      (action_mappings[:create] || []).each do |action|
        path_suffix = strong_resource_action == :update ? "/{id}/#{action}" : "/#{action}"
        swagger_path "#{base_path_for_swagger}#{path_suffix}" do
          create_action = JsonapiSwaggerHelpers::CreateAction.new \
            action, self, controller,
            strong_resource_action: strong_resource_action,
            tags: tags, description: descriptions[action], example: examples[action]
          create_action.generate
        end
      end

    end
  end
end
