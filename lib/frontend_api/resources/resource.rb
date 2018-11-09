require_relative 'nested_const_finder'

module FrontendApi
  class Resource
    MissingResource = Class.new(StandardError)

    class << self
      # DSL method
      def attribute(name, options={})
        options = options.merge(@scope) if @scope

        if block_given?
          define_method(name) do
            yield @object, @opts
          end
        else
          define_method(name) do
            @object.send(name)
          end
        end

        @attributes ||= {}
        # Set default options values
        @attributes[name] ||= {
          group: @group,
          array: false,
          type: :string,
          default: nil,
          writable: true,
          readable: true,
          required: false
        }
        # Update with options passed to the method
        # Allows to update attributes in extensions, subclasses, etc.
        @attributes[name].tap do |opts|
          opts[:default] = options[:type] == :boolean ? false : nil
          # %i[array type default required writable readable].each do |key|
          #   opts[key] = options[key] if options.key?(key)
          # end
          opts.merge!(options)
          opts[:writable] = !options[:readonly] if options.key?(:readonly)
          opts[:readable] = !options[:writeonly] if options.key?(:writeonly)
        end
      end

      # DSL method
      def association(name, options={})
        options = options.merge(@scope)
        assoc = model_class.association_reflection(name)

        if block_given?
          define_method(name) do
            val = yield(@object.send("#{name}_dataset"))
            val = val.first unless assoc.returns_array?
            val
          end
        else
          define_method(name) do
            @object.send(name, @opts)
          end
        end

        @associations ||= {}
        # Set default options values
        @associations[name] ||= {
          writable: true,
          readable: true,
          required: false
        }
        # Update with options passed to the method
        # Allows to update attributes in extensions, subclasses, etc.
        @associations[name].tap do |opts|
          # %i[required writable readable].each do |key|
          #   opts[key] = options[key] if options.key?(key)
          # end
          opts.merge!(options)
          opts[:writable] = !options[:readonly] if options.key?(:readonly)
          opts[:readable] = !options[:writeonly] if options.key?(:writeonly)
        end

        klass = Object.const_get(assoc[:class_name])
        @associations[name] = @associations[name].merge(
          class: klass,
          resource: klass.name.tableize.to_s
        )
        if assoc.returns_array?
          @associations[name][:type] = :many
          @associations[name][:attribute] = attr = :"#{name.to_s.singularize}_pks"
          attribute attr, options.merge(type: :integer, array: true, writeonly: true)
        else
          @associations[name][:type] = :one
          @associations[name][:attribute] = attr = assoc[:key]
          attribute attr, options.merge(association: name, type: :integer) if attr
        end
        @attributes[attr][:association] = name if attr
      end

      # DSL method
      def group(attr, options={})
        groups << attr
        attribute attr, { required: true, default: false, type: :boolean }.merge(options)
        @group = attr
        yield
      ensure
        @group = nil
      end

      # DSL method
      def scope(options={})
        @scope = options
        yield
      ensure
        @scope = {}
      end

      # DSL method
      def model(model_class)
        @model_class = model_class
      end

      def model_class
        @model_class ||= Object.const_get(name.split('::').last.gsub(/Resource\z/, ''))
      end

      def attributes
        @attributes ||= {}
      end

      def associations
        @associations ||= {}
      end

      def groups
        @groups ||= []
      end

      def writable_attributes
        find_attributes(writable: true)
      end

      def readable_attributes
        find_attributes(readable: true)
      end

      def required_attributes
        find_attributes(required: true)
      end

      def to_one_associations
        associations.select { |_, a| a[:type] == :one }
      end

      def to_many_associations
        associations.select { |_, a| a[:type] == :many }
      end

      def find_attributes(conditions)
        conditions.reduce(attributes) do |attributes, (option, value)|
          attributes.select { |_, o| o[option] == value }
        end
      end

      def resource_for(name, resource_nesting = Module.nesting)
        name = "#{name}Resource"
        NestedConstFinder.nested_const_get(resource_nesting, name)
      rescue NameError
        raise MissingResource, "Missing resource #{name}"
      end
    end

    def initialize(object, opts)
      @object = object
      @opts   = opts
    end
  end
end
