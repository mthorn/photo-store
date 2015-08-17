# From: https://gist.github.com/amenzhinsky/c961f889a78f4557ae0b
#
# Usage:
#
# validates :array_column, array: { length: { is: 20 }, allow_blank: true }
# validates :array_column, array: { numericality: true }
#
# It also supports sliced validation
#
# validates :array_column, array: { presence: true, slice: 0..2 }

class ArrayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, values)
    typecast_value = "#{attribute}_before_type_cast"
    typecast_array = "#{typecast_value}_original"

    record.singleton_class.class_eval do
      alias_method typecast_array, typecast_value
    end

    validators      = options.dup
    general_options = validators.extract!(:allow_nil, :allow_blank, :slice)

    collection = Array(values)
    collection.slice!(general_options[:slice]) if general_options[:slice]

    collection.each_with_index do |item, index|
      record.define_singleton_method(typecast_value) do
        record.send(typecast_array)[index]
      end

      next if item.nil?   && general_options[:allow_nil]
      next if item.blank? && general_options[:allow_blank]

      validate_item(record, attribute, item, validators)
    end
  ensure
    record.singleton_class.class_eval do
      alias_method  typecast_value, typecast_array
      remove_method typecast_array
    end
  end

  protected

  def validate_item(record, attribute, value, validators)
    validators.each do |name, args|
      options = { attributes: attribute }
      options.merge!(args) if args.is_a?(Hash)

      validator = validator_class(name).new(options)
      validator.validate_each(record, attribute, value)
    end
  end

  def validator_class(name)
    name = "#{name.to_s.camelize}Validator"
    name.constantize rescue "ActiveModel::Validations::#{name}".constantize
  end
end
