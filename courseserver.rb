require 'sinatra'
require './timetable.rb'
require 'json'

CURRENT_SEMESTER = '201301'

get '/' do
  "<html> 
  <body> 
  To find info on, say, ENGE 1024, GET /search?subj=enge&num=1024<br />
  More detailed information is available on this project's 
  <a href='http://github.com/benwr/timetable-adapter'>Github page.</a>
  </body>
  </html>"
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
    terms[:historical] = false
  else
    terms[:historical] = true
  end

  results = t.search(terms)
  JSON::dump(results)
end

get '/course/:subj/:num' do
  t = Timetable.new
  JSON::dump(t.course_info(params[:subj], params[:num]))
end
