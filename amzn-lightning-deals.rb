#!/usr/bin/env ruby

require 'mechanize'

agent = Mechanize.new
$link = 'http://www.amazon.com/gp/aw/gb/ld/1055398/'
$link = 'http://www.amazon.com/gp/aw/gb/ld/'
$page = agent.get $link

while true
  $page = $link.click if $link.respond_to? 'click'
  $link = $page.link_with(:text => "Next")

  break if $link.nil?
  $page.links.each do |link|
    if /\bshun\b/i =~ link.text
      puts "FOUND #{link.text}"
    end
  end
end
