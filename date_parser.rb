require 'logger'

module DateParser

	@logger = Logger.new(STDOUT)
	@logger.level = ENV['BRANNCALENDAR_LOG_LEVEL'] || Logger::INFO

	@monthnames = {
      jan: 1, feb: 2, mar: 3, apr: 4, mai: 5, jun: 6, jul: 7, aug: 8, sep: 9, okt: 10, nov: 11, des: 12
    }

    def self.parse(raw_date, time)
      @logger.debug "parsing date #{raw_date} #{time}"
      return '' if raw_date.nil? || raw_date.length == 0

      parts = raw_date.split("\n")
      @logger.debug "found #{parts}"
      day = parts[1].strip
      month = get_month(parts[2].strip)
      year = parts[3].strip
      hour, minute = time.split(":")
      @logger.debug "parsed month: #{month}, day: #{day}, hour: #{hour}, minute: #{minute}"
      Time.new(year, month, day, hour, minute)
    end

	def self.get_month(name)
	  @monthnames[name.to_sym]
	end
end