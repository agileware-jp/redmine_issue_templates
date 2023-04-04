# frozen_string_literal: true

# A mixin to display the appropriate field name when displaying a validation error message.
module AttributeNameMapper
  extend ActiveSupport::Concern

  module ClassMethods
    def attribute_map
      {}
    end

    def human_attribute_name(attr, options = {})
      map = ActiveSupport::HashWithIndifferentAccess.new(attribute_map)
      if map.has_key?(attr)
        l(map[attr])
      else
        super(attr, options)
      end
    end
  end
end
