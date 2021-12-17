class PrintableStringValidator < ActiveModel::EachValidator
  REGEX = /^[0-9a-zA-Z_.+()\-]*$/.freeze

  def validate_each(record, attribute, value)
    return if REGEX.match? value

    record.errors.add(attribute, "'#{value}' can only contain alphanumerics and _.-+()")
  end
end
