# encoding: utf-8

# Just a stupid test to see output
require 'rubygems'
require 'bundler/setup'
require './calendar.rb'

calendar = BrannCalendar.new(Logger::INFO)
puts calendar.get('obos-ligaen')