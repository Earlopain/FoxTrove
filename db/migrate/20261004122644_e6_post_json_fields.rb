class E6PostJsonFields < ActiveRecord::Migration[8.1]
  def change
    reversible do |dir|
      dir.up do
        if E6Post.where("post_json->'files' is null").any?
          raise StandardError, <<~MSG
            E6 post response format has changed. Run \
            docker compose run --rm foxtrove bin/rails r db/refresh_post_response_format.rb \
            before executing this migration.
          MSG
        end
      end
    end

    change_table :e6_posts, bulk: true do |t|
      t.string :post_direct_url, default: ""
      t.integer :post_score, default: 0
    end

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE e6_posts
          SET post_direct_url = post_json->'files'->'original'->'url'->>0,
              post_score      = (post_json->'stats'->'score'->'total')::integer
        SQL
      end
    end

    change_table :e6_posts, bulk: true do |t|
      t.change_default :post_direct_url, from: "", to: nil
      t.change_default :post_score, from: 0, to: nil
      t.change_null :post_score, false
    end
  end
end
