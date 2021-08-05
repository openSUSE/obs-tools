#!/usr/bin/ruby
require 'net/http'
require 'nokogiri'
require 'json'
# require 'pry'
require 'dotenv/load'

# OBS Configuration
OBS_API_URL = ENV.fetch('OBS_API_URL', 'https://api.opensuse.org')
OBS_PROJECT = ENV.fetch('OBS_PROJECT', 'OBS:Server:Unstable')
OBS_PACKAGE = ENV.fetch('OBS_PACKAGE', 'obs-server')
OBS_ARCHITECTURE = ENV.fetch('OBS_ARCHITECTURE', 'x86_64')
obs_distributions = ENV.fetch('OBS_REPOSITORIES', 'SLE_15_SP3')
OBS_REPOSITORIES = obs_distributions.split(' ')

# Trello configuration
TRELLO_CARD_ID = ENV.fetch('OBS_TRELLO_CARD_ID')
TRELLO_KEY = ENV.fetch('OBS_TRELLO_API_KEY')
TRELLO_TOKEN = ENV.fetch('OBS_TRELLO_API_TOKEN')
TRELLO_FAILED_IMAGE = ENV.fetch('OBS_TRELLO_FAILED_IMAGE', 'failed.jpg')
TRELLO_PASSED_IMAGE = ENV.fetch('OBS_TRELLO_PASSED_IMAGE', 'passed.jpg')

def get_package_status
  package_status = {}
  OBS_REPOSITORIES.each do |distro|
    uri = URI("#{OBS_API_URL}/public/build/#{OBS_PROJECT}/_result?package=#{OBS_PACKAGE}&arch=#{OBS_ARCHITECTURE}&repository=#{distro}")
    response = Net::HTTP.get_response(uri)

    abort(response.message) unless response.is_a?(Net::HTTPOK)

    status = Nokogiri::XML(response.body).css('status')

    # Bug: openSUSE/open-build-service#6924
    abort("Can't find architecture #{OBS_ARCHITECTURE}") if status.empty?

    package_status["#{distro}"] = status.first.attr('code')
  end
  package_status
end

def set_card_status(package_status = {})
  change_card_content(package_status)
  if package_status.values.include?('failed') || package_status.values.include?('broken')
    change_trello_cover(status: false)
  else
    change_trello_cover(status: true)
  end
end

def change_card_content(package_status = {})
  trello_card_content = "Last status scan for [OBS:Server:Unstable/obs-server](https://build.opensuse.org/package/show/OBS:Server:Unstable/obs-server) on #{Time.now}:\n\n"
  OBS_REPOSITORIES.each do |distro|
    trello_card_content += "#{distro}: #{package_status[distro]}\n"
  end
  card_desc_uri = URI("https://api.trello.com/1/cards/#{TRELLO_CARD_ID}/desc?key=#{TRELLO_KEY}&token=#{TRELLO_TOKEN}")
  request = Net::HTTP::Put.new(card_desc_uri)
  request.set_form_data({
    "value" => trello_card_content
  })
  Net::HTTP.start(card_desc_uri.hostname, card_desc_uri.port, use_ssl: true) { |http| http.request(request) }
end


def change_trello_cover(status:)
  image_name = status ? TRELLO_PASSED_IMAGE : TRELLO_FAILED_IMAGE
  cover_id = get_trello_image_id(image_name: image_name)
  unless cover_id
    puts "Warning: can't find image with name #{image_name}, not changing card cover"
    return
  end

  cover_uri = URI("https://api.trello.com/1/cards/#{TRELLO_CARD_ID}/idAttachmentCover?value=#{cover_id}&key=#{TRELLO_KEY}&token=#{TRELLO_TOKEN}")
  request = Net::HTTP::Put.new(cover_uri)
  response = Net::HTTP.start(cover_uri.hostname, cover_uri.port, use_ssl: true) { |http| http.request(request) }

  abort(response.message) unless response.is_a?(Net::HTTPOK)
end

def get_trello_image_id(image_name:)
  uri = URI("https://api.trello.com/1/cards/#{TRELLO_CARD_ID}/attachments?key=#{TRELLO_KEY}&token=#{TRELLO_TOKEN}")
  response = Net::HTTP.get_response(uri)

  abort(response.message) unless response.is_a?(Net::HTTPOK)

  attachments = JSON.parse(response.body)
  attachments.select!{ |image| image['name'] == image_name }

  return if attachments.empty?
  attachments.first['id']
end

set_card_status(get_package_status)
