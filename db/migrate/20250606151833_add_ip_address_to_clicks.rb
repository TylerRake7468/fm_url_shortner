class AddIpAddressToClicks < ActiveRecord::Migration[7.1]
  def change
    add_column :clicks, :ip_address, :string
  end
end
