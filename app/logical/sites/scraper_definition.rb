module Sites
  class ScraperDefinition < SimpleDefinition
    def initialize(enum_value:, display_name:, homepage:, gallery_templates:,
                   username_identifier_regex:, submission_template:)
      # TODO: https://bugs.ruby-lang.org/issues/14579 on ruby 3.1 release
      super(enum_value: enum_value, display_name: display_name, homepage: homepage,
            gallery_templates: gallery_templates, username_identifier_regex: username_identifier_regex)
      @submission_template = Addressable::Template.new(submission_template)
    end
  end
end
