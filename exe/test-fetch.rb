#!/usr/bin/env ruby

require_relative "../lib/relaton/plateau"

Relaton::Plateau::Fetcher.fetch_handbooks
Relaton::Plateau::Fetcher.fetch_technical_reports
