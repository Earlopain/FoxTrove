# frozen_string_literal: true

class AddMoreSites < ActiveRecord::Migration[7.0]
  def change
    values = %w[
      subscribestar
      kofi
      twitch
      picarto
      fanbox
      piczel
      linktree
      carrd
      youtube_channel
      youtube_vanity
      youtube_legacy
      gumroad
      discord
      telegram
      skeb
      pawoo
      baraag
      hentai_foundry
      pillowfort
      commishes
      furrynetwork
      facebook
    ]
    values.each do |value|
      execute("ALTER TYPE artist_url_sites ADD VALUE '#{value}';")
    end
  end
end
