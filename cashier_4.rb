require_relative 'calculate'
require 'csv'
require 'pry'

item_list = []

CSV.foreach('coffee.csv', headers: true) do |row|
  #binding.pry
  item_list << {name: row['name'], sku: row['SKU'], retail_price: row['retail price'], purchasing_price: row['purchasing price']}
end

item_key = []
(1..item_list.length).each do |number|
  item_key << number
end

  
item_list = Hash[item_key.zip(item_list)]

calculate = Calculate.new(item_list)

puts "==== Welcome to the Coffee Emporium! ===="
puts "Menu:"
item_list.each_with_index do |item,index|
  puts "#{index+1}. Name: #{item[1][:name]} Price: #{item[1][:retail_price]}"
end
puts "#{item_list.length + 1}. Complete Order"
calculate.enter_mode
calculate.get_selection
calculate.change_owed