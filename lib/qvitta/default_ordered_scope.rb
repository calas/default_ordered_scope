module Qvitta
  module DefaultOrderedScope
    def self.included(base)
      base.send(:extend, ClassMethods)
      super
    end

    module ClassMethods
      INVALID_TYPE_MSG = 'invalid options :mode, must be either String (ASC, DESC) or a Symbol(:asc, :desc)'
      INVALID_ARGUMENT_MSG = 'invalid arguments for order_by method'

      def order_by(clause)
        metaclass.instance_eval do
          define_method(:default_ordering) { build_order_from_argument(clause) }
        end

        # named_scope :ordered, lambda { |*order|
          scoped_methods << { :find => { :order => default_ordering }}
        # }
      end

      # sanitize the string adding the table name before each field
      # to prevent failing with using joins.
      def sanitize_order_string(string)
        s = string.gsub(/\s*,\s*/, ',')
        s = s.gsub(/[\w-]+/) { |m| "#{self.table_name}.#{m}" }
      end

      # build the order string from an array of fields.
      def build_order_string(fields, mode="ASC")
        fields.collect{ |f| "#{self.table_name}.#{f}" }.join(",") + " " + mode
      end

      # build the order string from hash argument options.
      def build_order_string_from_hash(options)
        raise InvalidArgument.new('invalid hash :fields key not found') unless options[:fields]

        case options[:fields]
        when String
          return self.sanitize_order_string(options[:fields]) + " " + self.build_mode_from_options(options)
        when Array
          return self.build_order_string(options[:fields], self.build_mode_from_options(options))
        else
          raise TypeError.new('invalid options :fields, must be either Array or a String')
        end
      end

      # build the order mode from the options
      def build_mode_from_options(options)
        if options[:mode]
          case options[:mode]
          when String
            return options[:mode]
          when Symbol
            return options[:mode].to_s.upcase
          else
            raise TypeError.new(INVALID_TYPE_MSG)
          end
        else
          return "ASC"
        end
      end

      def build_order_from_argument(arg)
        case arg
        when String
          return arg
        when Hash
          return build_order_string_from_hash(arg)
        else
          raise TypeError(INVALID_ARGUMENT_MSG)
        end
      end

      private

      def metaclass; class << self; self end; end
    end
  end
end
