class MakeSiteEnum < ActiveRecord::Migration[7.0]
  def change
    create_enum :artist_url_sites, %w[
      twitter
      furaffinity
      inkbunny
      sofurry
      deviantart
      artstation
      patreon
      pixiv
      weasyl
      tumblr
      reddit
      newgrounds
      vkontakte
      instagram
    ]

    change_table :artist_urls do |t|
      t.remove :site_id 
      t.enum :site_type, enum_type: :artist_url_sites, null: false
    end
    execute "CREATE UNIQUE INDEX index_artist_urls_on_site_and_identifier ON artist_urls (site_type, lower(identifier_on_site));"
  end
end
