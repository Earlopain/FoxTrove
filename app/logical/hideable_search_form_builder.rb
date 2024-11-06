class HideableSearchFormBuilder < BasicFormBuilder
  def input(attribute_name, **options, &)
    value = @options[:search_params][attribute_name]
    if options[:collection]
      options[:selected] = value
    elsif options[:as]&.to_sym == :checkbox
      options[:checked] = true if value == "1"
    else
      options[:value] = value
    end
    super
  end
end
