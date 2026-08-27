class ChangeArtistSubmissionIdentifierIndex < ActiveRecord::Migration[8.1]
  def up
    remove_index :artist_submissions, name: :index_artist_submissions_on_artist_url_and_identifier
    add_index :artist_submissions, %i[artist_url_id identifier_on_site], unique: true
  end
end
