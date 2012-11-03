#!/usr/bin/env ruby

require 'open-uri' 
require 'nokogiri'


class Timetable
  def initialize(url="https://banweb.banner.vt.edu/ssb/prod/HZSKVTSC", 
                 sem='201301',
                 search_format=".P_ProcRequest?CAMPUS=%s&TERMYEAR=%s&CORE_CODE=AR%s&SUBJ_CODE=%s&SCHDTYPE=%%25&CRSE_NUMBER=%s&crn=%s&open_only=&BTN_PRESSED=FIND+class+sections&inst_name=&PRINT_FRIEND=Y")
    @url = url
    @current_term = sem
    @search_format = search_format
  end

  def course_info(subj, id)  # returns a hash table with subject, id, title, 
    term = @current_term     # description, credit count 
    results = []
    format = @search_format
    semesters_checked = 0;
    while (((results = search(term, subj, id, semesters_checked > 1)) == []) and (semesters_checked < 8))
      semesters_checked += 1;
      term = previous_semester(term)
    end

    if not results
      return {}
    end

    course = {:subject => subj,
              :number  => id,
              :credits => results[0][:credits],
              :title   => results[0][:title],
              :type    => results[0][:type]}
    return course
  end

  def search(opts = {})
    # Returns an array of hash maps of course info for the given semester.
    #   Courses include the keys :subject :number :credits :title :crn :term
    #   :instructor :days :begin :end :type and :location

    o = {:subj        => "",
         :num         => "",
         :historical  => false,
         :crn         => "",
         :term        => @current_term,
         :campus      => 0,
         :area        => "%25"
    }.merge(opts)
    # Options are passed in a hash map

    search_string = format(@search_format, 
                           o[:campus],
                           o[:term], 
                           o[:area],
                           o[:subj].upcase, 
                           o[:num],
                           o[:crn])

    search_string = search_string + (o[:historical] ? "&history=Y" : '')

    resp = Nokogiri::HTML(open(@url + search_string))
    rows = resp.xpath('//tr')[firstrow..-1]

    result = []
    return result if rows.nil?

    firstrow = 1 # Different formatting requires different stating rows.

    rows.each do |row|
      tds = row.css('td')

      if tds.length > 10 # Either a regular row, or an "Additional Times" row
        name = tds[1].text.strip.split("-")
        subj = name[0]
        num = name[1]
        course = {:subject    => subj,
                  :number     => num,
                  :credits    => tds[4].text.strip.to_i,
                  :title      => tds[2].text.strip,
                  :crn        => tds[0].text.gsub(/\s|(&nbsp)/, ''),
                  :type       => tds[3].text.strip,
                  :seats      => tds[5].text,
                  :term       => o[:term],
                  :instructor => tds[6].text.strip}

        if tds.length == 12 # Regular row
          course[:days]      = [tds[7].text.strip.split]
          course[:begin]     = [tds[8].text.strip]
          course[:end]       = [tds[9].text.strip]
          course[:locations] = [tds[10].text.strip]
        end
        result.push(course)
      elsif tds.length == 10
        result[-1][:days].push(tds[5].text.strip.split)
        result[-1][:begin].push(tds[6].text.strip)
        result[-1][:end].push(tds[7].text.strip)
        result[-1][:locations].push(tds[8].text.strip)
      end
    end

    return result
  end

  private

  def previous_semester(sem)
    # semester strings are yyyytt, where tt = 01 means spring, tt = 06
    # means summer I, tt = 07 is summer II, and tt = 09 is fall.
    case sem[-1]
    when '1'
      return (sem[0..3].to_i  - 1).to_s + '09'
    when '6'
      return sem[0..3] + '01'
    when '7'
      return sem[0..3] + '06'
    when '9'
      return sem[0..3] + '07'
    else
      raise ValueError, "Does not appear to be a valid term identifier: #{sem}"
    end
  end
end
