require 'concurrent'
require 'pry'
require 'benchmark'

def end_of_year
  Time.new(2019, 1) - 1
end

def months_and_days
  months = []
  days = 1.upto(11).map do |month|
    start_day = Time.new(2018, month)
    end_day = Time.new(2018, month + 1) - 1
    months.<<(convert_to_bool((start_day..end_day).to_a))
  end
  months.<<convert_to_bool((Time.new(2018, 12)..end_of_year).to_a)
end

def convert_to_bool(days)
  days.map {|x| false}
end


puts Benchmark.measure {
   20.times do
    months_and_days
   end
}
