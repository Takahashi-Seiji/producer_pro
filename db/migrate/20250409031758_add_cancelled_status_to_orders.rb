class AddCancelledStatusToOrders < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      ALTER TABLE orders
      DROP CONSTRAINT IF EXISTS check_status;
      
      ALTER TABLE orders
      ADD CONSTRAINT check_status
      CHECK (status IN ('pending', 'confirmed', 'delivered', 'cancelled'));
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE orders
      DROP CONSTRAINT IF EXISTS check_status;
      
      ALTER TABLE orders
      ADD CONSTRAINT check_status
      CHECK (status IN ('pending', 'confirmed', 'delivered'));
    SQL
  end
end
