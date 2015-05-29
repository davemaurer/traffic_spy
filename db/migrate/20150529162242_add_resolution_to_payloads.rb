class AddResolutionToPayloads < ActiveRecord::Migration
  def change
    add_column :payloads, :resolution, :text
  end
end
