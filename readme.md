# Timetable Adapter #

Virginia Tech's 
[timetable of courses](https://banweb.banner.vt.edu/ssb/prod/HZSKVTSC.P_ProcRequest), 
a component of the Banner system used here (and at many other universities),
sucks. There's no reasonable API, the information about classes isn't
available from any one place, and it's just generally ugly. This is an
attempt to build an adapter for it. It should be relatively easy to modify
to work with other universities' systems.

## Architecture ##

The main thing here is the "Timetable" class. It does all of the actual
communication with Banner. The most important method is "search", which
takes a bunch of optional arguments, each of which will be passed
along to the banner web system. The results of this search are then
returned in a list of ruby hash maps.

## API ##

This data is exposed through the courseserver.rb web application.

* `/search?subj=ece&num=2504&crn=120931&term=201201&type=L`
  searches for exactly what you would expect. All parameters are optional,
  but keep in mind that banner has restrictions on what it will search for.
  If you leave out the term, you might expect that you would get results
  for all terms. Unfortunately, Banner disallows this. 
* `/course/ece/2504`
* `/crn/120931`
