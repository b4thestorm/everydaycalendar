require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'pry'
  

configure do
  set :static, true
  set :root, File.dirname(__FILE__)
  set :public, 'public'
  
  enable :sessions
  set :session_secret, 'calendar_session' 
end

helpers do 
  def pretty_month(month)
    DateTime.new(2018, month).strftime("%b")
  end
  

  def total_days
        # cpu time system cpu  user/cpu    
        #0.000093   0.000015   0.000108 (  0.000102) w/o Futures
        #0.000091   0.000019   0.000110 (  0.000106) w/ futures
        number_true = session[:history].map {|month| month.select {|day| day == true}}
        number_true.map {|month| month.count }.inject {|sum, el| sum + el }
  
  end 
end 

before do 
  session[:history] ||= [] 
end

get '/' do
  @days = session["history"]
  @day_count = total_days

  erb :index, layout: :layout
end

get '/toggle' do
  month_index = params[:month].to_i
  day_index = params[:day].to_i
  position = session["history"][month_index][day_index]
    if position == false 
      binding.pry
      session["history"][month_index][day_index] = true
    else
      session["history"][month_index][day_index] = false
    end
  redirect '/'
end

get '/clear' do
  session["history"] = months_and_days
  redirect '/'
end

def months_and_days #this is a huge improvement
  #0.000459   0.000007   0.000466 (  0.000459) w/o futures
  #0.000079   0.000008   0.000087 (  0.000081) w/o calling value
  months = []
  days = 1.upto(11).map do |month|
    start_day = DateTime.new(2018, month)
    end_day = DateTime.new(2018, month + 1) - 1
    months.<<(convert_to_bool((start_day..end_day).to_a))
  end
  months.<<convert_to_bool((DateTime.new(2018, 12)..end_of_year).to_a)
end

def convert_to_bool(days)
  days.map {|x| false}
end

def end_of_year
  DateTime.new(2019, 1) - 1
end
