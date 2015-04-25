require 'logger'
require './date_parser'

class FixtureFetcher

  def initialize(competition, level=Logger::DEBUG)
    @competition = competition

    @logger = Logger.new(STDOUT)
    @logger.level = ENV['BRANNCALENDAR_LOG_LEVEL'] || Logger::INFO

    @today = Time.new
  end

  def self.all_matches(competition)
    instance = FixtureFetcher.new(competition)
    instance.fetch_all_matches
  end

  def fetch_all_matches
    @logger.debug "getting all matches"
    
    rows.collect { | row |
      @logger.debug "traversing rows in table"
      handle_row(row)
    }.select { | row | row[:date] > @today }

  end

  def rows
    document = fetch_document
    current_season = document.xpath("//li[@class='currentFixtureSet']").first
    current_season.xpath(".//tr[@data-competition='#{@competition}']")
  end

  def fetch_document
    @logger.debug "fetching document"
    html = open('http://www.brann.no/fixtures-and-results').read
    html.encode('utf-8')
    @logger.debug "body length: #{html.length} characters"
    Nokogiri::HTML(html)
  end

  def handle_row(row)
    data = {}
    data[:date] = DateParser::parse(row.xpath('td').first.text, row.css('td.date').text)
    data[:home_team] = row.css('td.homeTeam').text
    data[:away_team] = row.css('td.awayTeam').text
    channel = row.css('td.tvChannel').text.strip
    unless channel == "-"
      data[:tv] = channel
    end
    @logger.debug "parsed row: #{data}"

    data
  end
  
end