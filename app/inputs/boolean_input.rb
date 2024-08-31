class BooleanInput < SimpleForm::Inputs::BooleanInput
  # Fix styling because the input appears before the label
  def label_input(wrapper_options = nil)
    label(wrapper_options) + input(wrapper_options)
  end

  def label_text
    "#{super}?"
  end
end
