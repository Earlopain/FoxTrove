# frozen_string_literal: true

class MakeSiteInternalNameIndexUnique < ActiveRecord::Migration[6.1]
  def change
    remove_index :sites, :internal_name
    add_index :sites, :internal_name, unique: true
  end
end
