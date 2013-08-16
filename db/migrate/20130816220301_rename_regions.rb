class RenameRegions < ActiveRecord::Migration
  def change

    Region.all.each do |region|
      region.name = region.name.sub ' район', ''
      region.name = region.name.sub 'поселение ', ''
      region.save!
    end

  end
end
