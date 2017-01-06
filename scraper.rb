#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'pry'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_table_elected(url, term)
  noko = noko_for(url)
  noko.xpath('//h3[contains(.,"Island Council")]/following-sibling::table[1]/tr[td[contains(.,"Elected")]]').each do |tr|
    tds = tr.css('td')
    data = {
      name:     tds[0].text.tidy,
      wikiname: tds[0].css('a[href*="/wiki/"]/@title').text,
      party:    'Independent',
      term:     term,
      source:   url,
    }
    ScraperWiki.save_sqlite(%i(name term), data)
  end
end

def scrape_table_green(url, term)
  noko = noko_for(url)
  noko.xpath('//h3[contains(.,"Island Council")]/following-sibling::table[1]//tr[@bgcolor="#CCFFCC"]').each do |tr|
    tds = tr.css('td')
    data = {
      name:     tds[0].text.tidy,
      wikiname: tds[0].css('a[href*="/wiki/"]/@title').text,
      party:    'Independent',
      term:     term,
      source:   url,
    }
    ScraperWiki.save_sqlite(%i(name term), data)
  end
end

def scrape_list(url, term)
  noko = noko_for(url)
  section = noko.xpath('//h2[contains(.,"Results")]')
  ul = section.xpath('following-sibling::h2 | following-sibling::ul').slice_before { |e| e.name == 'h2' }.first.first
  ul.css('li').each do |li|
    data = {
      name:     li.text.tidy,
      wikiname: li.css('a[href*="/wiki/"]/@title').text,
      party:    'Independent',
      term:     term,
      source:   url,
    }
    ScraperWiki.save_sqlite(%i(name term), data)
  end
end

scrape_table_elected('https://en.wikipedia.org/wiki/Pitcairn_Islands_general_election,_2013', '2013')
scrape_list('https://en.wikipedia.org/wiki/Pitcairn_Islands_general_election,_2011', '2011')
scrape_table_green('https://en.wikipedia.org/wiki/Pitcairn_Islands_general_election,_2009', '2009')
