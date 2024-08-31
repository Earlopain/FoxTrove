class HideableSearchFormBuilder < SimpleForm::FormBuilder
  def input(attribute_name, options = {}, &)
    value = @options[:search_params][attribute_name]
    options[:input_html] ||= {}
    if options[:collection]
      options[:selected] = value
    elsif options[:as]&.to_sym == :boolean
      options[:input_html][:checked] = true if value == "1"
    else
      options[:input_html][:value] = value
    end
    super
  end
end
