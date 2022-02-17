class HideableSearchFormBuilder < SimpleForm::FormBuilder
  def input(attribute_name, options = {}, &block)
    value = @options[:search_params][attribute_name]
    options[:input_html] ||= {}
    if options[:collection]
      options.merge! selected: value
    elsif options[:as]&.to_sym == :boolean
      options[:input_html].merge! checked: true if value == "1"
    else
      options[:input_html].merge! value: value
    end
    super(attribute_name, options, &block)
  end
end
