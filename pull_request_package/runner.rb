#!/usr/bin/env ruby
# frozen_string_literal: true
require 'rubygems'
require "bundler"
Bundler.require(:default)

opts = Slop.parse do |o|
  o.string '-f', '--filename', 'configuration file to be used', required: true
end


pull_request_builder_config = YAML.load_file(opts[:filename])
fetcher = PullRequestBuilder::GithubPullRequestFetcher.new(pull_request_builder_config)
fetcher.pull
fetcher.delete
