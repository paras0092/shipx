
require 'nokogiri'
require 'open-uri'

class AddCloumnLatAndLngToCitieTable < ActiveRecord::Migration[6.0]
  disable_ddl_transaction! # To disable the default transaction locking behavior.
  def up
    ActiveRecord::Base.transaction do 
      add_column :cities, :lat, :float, default: nil
      add_column :cities, :lng, :float, default: nil
    end

    dataset={}
    doc = Nokogiri::HTML(open('https://www.latlong.net/category/cities-102-15.html'))            
    table = doc.at('table')         
    table.search('tr').each do |tr|             
      cells = tr.search('th, td')             
      dataset.merge!({cells[0].text.split(',').first => [cells[1].text,cells[2].text]})         
    end          
    # for dont take to much time update them in batches.
    City.find_in_batches.with_index do |result, batch|  
      result.each do |city|           
        city.update_columns(:lat => dataset[city.name]&.first,:lng => dataset[city.name]&.second)  
      end       
    end

  end
  def down
    ActiveRecord::Base.transaction do
      remove_column :cities, :lat
      remove_column :cities, :lng
    end
  end
end
