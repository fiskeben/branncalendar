# encoding: utf-8
require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require './calendar'

before do
  logger = Logger.new(STDERR)
  expires 2538000, :public, :must_revalidate
end

get '/' do
  erb :index
end

get '/kalender' do
  begin
    calendar = BrannCalendar.new
    output = calendar.get('obos-ligaen')
    status 200
    headers \
      "Content-type" => "text/calendar; charset=utf-8",
      "Content-Disposition" => "inline; filename=brannkamper.ics"
    body output
  rescue => e
    logger.error e
    halt 500, 'ouch'
  end
end
