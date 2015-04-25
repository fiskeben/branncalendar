# encoding: utf-8

require 'open-uri'
require 'nokogiri'
require 'logger'
require './fixture_fetcher'
require 'waffle_cal'

class BrannCalendar
  attr_reader :date_time_format, :logger, :today, :competition
  
  def initialize(level = Logger::WARN)
    @logger = Logger.new(STDOUT)
    @logger.level = level
    
    @calendar = WaffleCal::Calendar.new(prod_id)
  end
  
  def get(competition)
    FixtureFetcher.all_matches(competition).each do | match |
      next unless match[:home_team]

      event = WaffleCal::Event.new

      event.uid = "#{match[:home_team]}-#{match[:away_team]}"
      event.summary = "#{match[:home_team]} - #{match[:away_team]}"
      
      description = event.summary      
      description += " (vises på #{match[:tv]})" if match[:tv]

      event.description = description
      event.start_time = match[:date]
      event.end_time = (match[:date] + match_length)
      
      event.location = (match[:home_team] == 'Brann') ? 'Brann Stadion' : ''

      @calendar << event

    end
    @calendar.to_s
  end
  
  def write_file
    File.open('brannkalender.ics', 'w') do | file |
      file.write get
    end
  end
  
  protected

  def prod_id
    WaffleCal::ProdId.new({entity_name: 'fiskeben.dk', product_name: 'brannkalender', language: 'no'})
  end

  def match_length
    60 * 105
  end
end
