class AddColumnYoutubeId < ActiveRecord::Migration[7.1]
  def change
    add_column :sources, :youtube_id, :string
  end
end
