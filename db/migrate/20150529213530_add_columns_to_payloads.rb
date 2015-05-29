class AddColumnsToPayloads < ActiveRecord::Migration
  def change
    add_column :payloads, :requested_at, :text
    add_column :payloads, :request_type, :text
    add_column :payloads, :referred_by, :text
    add_column :payloads, :event_name, :text
  end
end
