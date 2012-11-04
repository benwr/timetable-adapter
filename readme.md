# Timetable Adapter #

If you're a computer (or a programmer), Virginia Tech's 
[timetable of courses](https://banweb.banner.vt.edu/ssb/prod/HZSKVTSC.P_ProcRequest), 
a component of the Banner system used here (and at many other universities),
sucks. There's no reasonable API, the information about classes isn't
available from any one place, and it's just generally ugly. This is an
attempt to build an adapter for it. It should be relatively easy to modify
to work with other universities' systems.

You can run an instance of it, or you can check out [the instance I have
running.](http://courses.benwr.net)

## Architecture ##

The main thing here is the "Timetable" class. It does all of the actual
communication with Banner. The most important method is "search", which
takes a bunch of optional arguments, each of which will be passed
along to the banner web system. The results of this search are then
returned in a list of ruby hash maps.

## API ##

This data is exposed through the courseserver.rb web application.

* `/search?subj=ece&num=2504&crn=120931&term=201201&type=L`
  searches for exactly what you would expect. Available parameters are
  * "subj" - For example, "als" 
  * "num" - For example, "2114" 
  * "historical" - Indicates whether or not to search the historical timetable.
      It's assumed to be false. If it's set to true (using the value "Y"),
      more semesters can be searched, but the CRNs aren't available.
  * "crn" - Searches for a particular CRN. You should expect to receive a JSON
      list containing either one or zero courses.
  * "term" - Four-digit year, and a two-digit semester indicator. 201301 is
    Spring 2013, 201306 is Summer I 2013, 201307 is Summer II 2013, and 201309
    is Fall 2013.
  * "campus" - Campus identifier. 0 is Blacksburg, 2 is Western, 3 is Valley,
      4 is National Capital Region, 6 is Central, 7 is Hampton Roads Center,
      8 is Capital, 9 is Other, and 10 is Virtual.
  * "area" - Two-digit Curriculum for Liberal Education area. 01 is Writing
      and Discourse; 02 is Ideas, Cultural Traditions, and Values; 03 is Society
      and Human Behavior; 04 is Scientific Reasoning and Discovery; 05 is
      Quantitative and Symbolic Reasoning; 06 is Creativity and Aesthetic
      Experience; 07 is Critical Issues in a Global Context 1W is Writing
      Intensive.

  All parameters are optional. Leaving most options unspecified searches among
  all possible values, but "campus" and "term" have default values of 0 and
  201301, respectively, because Banner doesn't allow you to leave these fields
  blank.

* `/course/ece/2504` returns only the date-nonspecific information about a
    course.

* `/crn/120931` is not yet implemented, but should be easy.

## Data returned ##

All returned data is simple JSON. `/search` returns a list of dictionaries,
and `/course/ece/2504` returns a single dict. To see it, [just check it 
out!](http://courses.benwr.net/search?subj=engl&num=2744)
