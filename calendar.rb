# encoding: utf-8

require 'open-uri'
require 'nokogiri'
require 'logger'

class BrannCalendar
  attr_reader :date_time_format, :logger, :today
  
  def initialize(level = Logger::WARN)
    @logger = Logger.new(STDOUT)
    @logger.level = level
    
    @date_time_format = "%Y%m%dT%H%M00"
    @today = Time.new
    @monthnames = {
      jan: 1, feb: 2, mar: 3, apr: 4, mai: 5, jun: 6, jul: 7, aug: 8, sep: 9, okt: 10, nov: 11, des: 12
    }
  end
  
  def get
    output = []
    output << "BEGIN:VCALENDAR"
    output << "METHOD:PUBLISH"
    output << "VERSION:2.0"
    output << "PRODID:-//fiskeben.dk//Brannkalender//NO"

    all_matches.each do | match |
      next if (match['home_team'].nil?)

      match_string = "#{match['home_team']} - #{match['away_team']}"
      location = (match['home_team'] == "Brann") ? "Brann Stadion" : ""
      uid = "#{match['home_team']}-#{match['away_team']}"

      start_time = match['date'].strftime(@date_time_format)
      end_time = (match['date'] + 60*105).strftime(@date_time_format)

      datestamp = Time.new.strftime(@date_time_format)
      description = "#{match['home_team']} - #{match['away_team']}"
      unless match['tv'].nil?
        description = description + " (vises på #{match['tv']})"
      end

      output << "BEGIN:VEVENT"
      output << "DTSTART:#{start_time}"
      output << "DTEND:#{end_time}"
      output << "UID:#{uid}"
      output << "SUMMARY:#{match_string}"
      output << "LOCATION:#{location}"
      output << "DESCRIPTION:#{description}"
      output << "END:VEVENT"


    end
    output << "END:VCALENDAR"
    output.join("\r\n")
  end
  
  def write_file
    File.open('brannkalender.ics', 'w') do | file |
      file.write get
    end
  end
  
  def get_month(name)
    @monthnames[name.to_sym]
  end
  
  def parse_date(raw_date, time)
    @logger.debug "parsing date #{raw_date} #{time}"
    return "" if raw_date.nil? or raw_date.length == 0

    parts = raw_date.split("\n")
    logger.debug "found #{parts}"
    day = parts[1].strip
    month = get_month(parts[2].strip)
    year = parts[3].strip
    hour, minute = time.split(":")
    @logger.debug "parsed month: #{month}, day: #{day}, hour: #{hour}, minute: #{minute}"
    Time.new(year, month, day, hour, minute)
  end

  def fetch_document
    @logger.debug "fetching document"
    html = open('http://www.brann.no/fixtures-and-results').read
    html.encode('utf-8')
    Nokogiri::HTML(html)
  end

  def handle_row(row)
    #@logger.debug "handling a row: #{row}"
    data = {}
    data['date'] = parse_date(row.xpath('td').first.text, row.css('td.date').text)
    data['home_team'] = row.css('td.homeTeam').text
    data['away_team'] = row.css('td.awayTeam').text
    channel = row.css('td.tvChannel').text.strip
    unless channel == "-"
      data['tv'] = channel
    end
    @logger.debug "parsed row: #{data}"
    data
  end

  def all_matches
    @logger.debug "getting all matches"
    matches = []
    document = fetch_document
    current_season = document.xpath("//li[@class='currentFixtureSet']").first
    current_season.xpath(".//tr[@data-competition='tippeligaen']").each do | row |
      @logger.debug "traversing rows in table"
      data = handle_row(row)
      matches.push(data) if data['date'] > @today
    end
    matches
  end
end
