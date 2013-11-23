require 'date'
require 'pry'
require 'csv'
class Calculate
  def initialize(item_list)
    @item_list = item_list
    @subtotal = 0
    @sale_complete = false
    @quantities = Hash.new(0)
  end

  def enter_mode
  puts "Enter Sales Mode (1) or View Sale Logs? (2)"
  puts "To exit program (3)"
  user_mode = gets.chomp.to_i
    if user_mode == 1
      get_selection
    elsif user_mode == 2
      view_logs
    elsif user_mode == 3
      abort
    else
      puts "Please enter (1) or (2)."
      enter_mode
    end
  end

  def view_logs
    log_list = get_logs
    puts "Enter a date that you wish to view the sales log of."
    puts "Example: November 22 2013 // 22 Nov 2013."
    user_date = gets.chomp
    user_date = DateTime.parse(user_date).yday
    logs = log_list.select{|k,v| user_date == DateTime.parse(v[:date]).yday}
    if logs.empty?
      puts "No sales data was found."
      view_logs
    else
      total_gross = 0
      cost = 0
      logs.values.each do |log|
        puts "Item: #{log[:name]}, Date of Purchase: #{log[:date]}, # of items sold: #{log[:quantity]}"
        total_gross += log[:retail_price].to_f * log[:quantity].to_i
        cost += log[:purchasing_price].to_f * log[:quantity].to_i
      end
      puts "Total Gross: $#{total_gross}   Cost of Goods: $#{cost}\n"
    end
    continue_logs
  end

  def continue_logs
  puts "Look at other logs?"
    answer = gets.chomp
    if answer == "yes"  
      view_logs
    elsif answer == "no"
      enter_mode
    else
      puts "Please enter yes or no."
      continue_logs
    end
  end

  def get_logs
    log_list = []
      CSV.foreach('logs.csv', headers: true) do |row| 
        log_list << {name: row['name'], sku: row['SKU'], retail_price: row['retail price'], purchasing_price: row['purchasing price'], date: row['date'], quantity: row['quantity']}  
      end
    log_key = []
    (1..log_list.length).each do |number|
      log_key << number
    end
    log_list = Hash[log_key.zip(log_list)]
  end

  def get_selection
    while @sale_complete != true
      puts "Make a selection:"
      selection = gets.chomp
      
      if (1..@item_list.length).to_a.include?(selection.to_i)
        quantity = get_quantity
        add_item(selection.to_i, quantity.to_i)
      elsif selection.to_i == @item_list.length + 1
        sale_complete
      else
        puts "Invalid input. Try again."
        get_selection
      end
    end
  end

  def get_quantity
    puts "How many bags?"
    quantity = gets.chomp
    
    if quantity.to_i <= 0 || quantity =~ /([a-zA-Z])/
      puts "Invalid input. Try again."
      quantity = get_quantity
    end
    quantity
  end

  def add_item(selection, quantity)
    if (1..@item_list.length).include?(selection)
      @quantities[@item_list[selection][:name]] += quantity
      @subtotal += @item_list[selection][:retail_price].to_f * quantity
      puts "Subtotal: $#{sprintf('%.2f', @subtotal)}"
    end
  end

  def sale_complete
    @sale_complete = true
    puts "=== Sale Complete ===\n"
    @quantities.each do |item, quantity|
      puts "#{item} #{quantity}"
      store_information(item, quantity)
    end
    puts "Subtotal: $#{sprintf('%.2f', @subtotal)}"
  end

  def store_information(item, quantity)
    #when we call values it is wrapped in an array so we call [0] to get the correct number.
    #.select{|k,v| v} looks for value that is equal to [:name] that is equal to item mentioned above.
    current = @item_list.select{|k,v| v[:name] == item}.values[0]
    data = [item, current[:sku], current[:retail_price], current[:purchasing_price], Time.now, quantity].join(",")
    File.open('logs.csv', 'a') do |logs|
      logs.puts(data)
    end
  end

  def change_owed
    puts "What is the amount given?"
    given = gets.chomp

    if given.to_f <= 0 || given =~ /[a-zA-Z]/
      puts "Invalid input. Please try again."
      change_owed
    end

    if @subtotal.to_f <= given.to_f
      change = given.to_f - @subtotal.to_f
      puts "Thank you! The change given will be $#{sprintf('%.2f', change)}"
      puts "Date: " + Time.new.strftime("%Y %B %d, %I:%M%p")
      abort
    else
      change = @subtotal.to_f - given.to_f
      puts "Customer still needs to pay $#{sprintf('%.2f', change)}!"
      change_owed
    end
  end
end