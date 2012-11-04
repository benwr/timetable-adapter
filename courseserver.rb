require 'sinatra'
require './timetable.rb'
require 'json'

CURRENT_SEMESTER = '201301'

get '/' do
  "To find info on, say, ENGE 1024, GET /search?subj=enge&num=1024"
end

get '/search' do
  t = Timetable.new
  terms = {}
  [:subj, :num, :crn, :term, :campus, :area].each do |field|
    if params[field]
      terms[field] = params[field]
    end
  end

  if params[:historical] != "Y"
    terms[:historical] = true
  else
    terms[:historical] = false
  end

  results = t.search(terms)
  JSON::dump(results)
end

get '/course/:subj/:num' do
  t = Timetable.new
  JSON::dump(t.course_info(params[:subj], params[:num]))
end
