#!/usr/bin/env ruby

require_relative "../lib/relaton/plateau"

Relaton::Plateau::Scraper.scrape_handbooks
Relaton::Plateau::Scraper.scrape_technical_reports
