class AddBrowserAndOsToPayloads < ActiveRecord::Migration
  def change
    add_column :payloads, :browser, :text
    add_column :payloads, :platform, :text
  end
end
