require 'sinatra'
require './timetable.rb'
require 'json'

CURRENT_SEMESTER = '201301'

get '/' do
  "To find info on, say, ENGE 1024, GET /ENGE/1024"
end

get '/detail/:subj/:num' do
  t = Timetable.new
  JSON::dump(t.search(CURRENT_SEMESTER, params[:subj], params[:num], false))
end

get '/detail/:sem/:subj/:num' do
  t = Timetable.new
  JSON::dump(t.search(params[:sem], 
                      params[:subj], 
                      params[:num], 
                      params[:sem] != CURRENT_SEMESTER ))
end

get '/:subj/:num' do
  t = Timetable.new
  JSON::dump(t.course_info(params[:subj], params[:num]))
end
