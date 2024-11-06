class BasicFormBuilder < ActionView::Helpers::FormBuilder
  def initialize(object_name, object, template, options)
    options[:class] ||= "basic-form"
    super
  end

  def input(attribute, label: attribute, as: nil, **options)
    as ||= :select if options[:collection]
    label = label.to_s.titleize
    label += "?" if as == :checkbox

    @template.content_tag(:div, class: "input") do
      label(attribute, label) + choose(attribute, as, options)
    end
  end

  private

  def choose(attribute, type, options)
    case type
    when :textarea
      text_area(attribute, options)
    when :file
      file_field(attribute, options)
    when :select
      options[:collection] ||= [["Yes", true], ["No", false]]
      select(attribute, options.delete(:collection), options)
    when :checkbox
      check_box(attribute, options)
    else
      text_field(attribute, options)
    end
  end
end
