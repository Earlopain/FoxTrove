# frozen_string_literal: true

require "spec_helper"

RSpec.describe Site, type: :model do
  context "for each sites" do
    Site.all.each do |site|
      it "parses its templates" do
        expect(site.artist_url_identifier_templates).to be
      end

      it "contains the correct capture for each template" do
        site.artist_url_identifier_templates.each do |template|
          expect(template.variables.include?("site_artist_identifier")).to be true
        end
      end
    end
  end
end
