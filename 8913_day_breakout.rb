require 'csv'
require 'date'

LONG = 1
SHORT = 2
STOP_LONG = 3
STOP_SHORT = 4
STAY = 5

close_data = Hash[ CSV.read('coindesk_close_data.csv').map do |row|
  [row[0],row[1].to_f]
end ]

def daily_calc(today, data)
  prices = []

  (today - 90..today).each do |date|
    prices.push(data[date.strftime('%-m/%-d/%y')])
  end

  atr = prices.reduce(:+) / prices.length
  
  h_89 = prices.max.to_f
  l_89 = prices.min
  h_13 = prices.last(13).max
  l_13 = prices.last(13).min

  cur_price = data[today.strftime('%-m/%-d/%y')]

  return LONG if h_89 <= cur_price
  return SHORT if  l_89 >= cur_price
  return STOP_LONG if l_13 >= cur_price
  return STOP_SHORT if h_13 <= cur_price
  return STAY
end

def test_from(start, stop, data)
  buys, shorts, results = [],[], []

  (start..stop).each do |date|
    calc = daily_calc(date, data)
    cur = data[date.strftime('%-m/%-d/%y')]
    if LONG == calc
      buys.push(cur)
    elsif SHORT == calc
      shorts.push(cur)
    elsif STOP_LONG == calc
      sum = 0
      unless buys.length.zero?
        buys.each { |e| sum += cur - e }
        results.push(sum)
      end
    elsif STOP_SHORT == calc
      sum = 0
      unless shorts.length.zero?
        shorts.each { |e| sum += e - cur }
        results.push(sum)
      end
    else
      #puts "STAY"
    end
  end
  results.inject(:+)
end

#today = DateTime.new(ARGV[0].to_i, ARGV[1].to_i, ARGV[2].to_i)
today = DateTime.now

#puts test_from(today - 360, today, close_data).round(2)
puts "Today (#{today.strftime('%-m/%-d/%y')}) you should... #{daily_calc(today, close_data)}"
puts "KEY : LONG = 1, SHORT = 2, STOP_LONG = 3, STOP_SHORT = 4, STAY = 5"
