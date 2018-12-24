require 'protobuf/field/varint_field'

module Protobuf
  module Field
    class IntegerField < VarintField

      ##
      # Public Instance Methods
      #
      def acceptable?(val)
        int_val = if val.is_a?(Integer)
                    return true if val >= 0 && val < INT32_MAX # return quickly for smallest integer size, hot code path
                    val
                  elsif val.is_a?(Numeric)
                    val.to_i
                  else
                    Integer(val, 10)
                  end

        int_val >= self.class.min && int_val <= self.class.max
      rescue
        false
      end

      def coerce!(val)
        fail TypeError, "Expected value of type '#{type_class}' for field #{name}, but got '#{val.class}'" unless acceptable?(val)
        return val.to_i if val.is_a?(Numeric)
        Integer(val, 10)
      rescue ArgumentError
        fail TypeError, "Expected value of type '#{type_class}' for field #{name}, but got '#{val.class}'"
      end

      def decode(value)
        value -= 0x1_0000_0000_0000_0000 if (value & 0x8000_0000_0000_0000).nonzero?
        value
      end

      def encode(value)
        # original Google's library uses 64bits integer for negative value
        ::Protobuf::Field::VarintField.encode(value & 0xffff_ffff_ffff_ffff)
      end

    end
  end
end
