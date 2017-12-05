#!/usr/bin/env ruby

require 'yaml'
require_relative 'github_labeling_bot'

config = YAML.load_file('config/config.yml')

bot = GithubLabelingBot.new(config)

bot.run
