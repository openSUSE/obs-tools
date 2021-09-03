#!/usr/bin/ruby
require 'dotenv/load'
require 'pry'
require 'faraday'
require 'xmlhash'
require 'logger'

@logger = Logger.new(STDOUT)
original_formatter = Logger::Formatter.new
@logger.formatter = proc { |severity, datetime, progname, msg|
  original_formatter.call(severity, datetime, progname, msg.dump)
}

OPENQA_URL = ENV.fetch('OBS_TOOLS_OPENQA_URL', 'https://openqa.opensuse.org')
OPENQA_API_KEY = ENV.fetch('OBS_TOOLS_OPENQA_KEY')
OPENQA_API_SECRET = ENV.fetch('OBS_TOOLS_OPENQA_SECRET')

FREQUENCY = ENV.fetch('OBS_TOOLS_RUN_EVERY', 10).to_i

def fetch_binaries(version)
  response = Faraday.get("https://api.opensuse.org/public/build/OBS:Server:#{version}/images/x86_64/OBS-Appliance:qcow2")
  unless response.status == 200
    @logger.fatal("Could not fetch binaries: #{response.status}")
    abort
  end

  Xmlhash.parse(response.body)
end

def fetch_image(version)
  binaries = fetch_binaries(version)
  image = binaries['binary'].select { |binary| binary['filename'].end_with?('.qcow2') }.last
  unless image
    @logger.fatal('No qcow2 image found')
    abort
  end

  image['mtime'] = DateTime.strptime(image['mtime'], '%s')
  image['build_id'] = "#{image['filename'].gsub('obs-server.x86_64-', '').gsub('Build', '').gsub('.qcow2', '')}"
  image
end

def trigger_run(version:)
  qcow2_image = fetch_image(version)

  frequency_minutes_ago = DateTime.now - (FREQUENCY/1440.0)
  unless qcow2_image['mtime'] >= frequency_minutes_ago
    @logger.info("No new build found for #{version}...")
    return
  end

  options = "isos post --host #{OPENQA_URL}"
  options << " --apikey #{OPENQA_API_KEY}"
  options << " --apisecret #{OPENQA_API_SECRET}"
  options << " HDD_1_URL=https://download.opensuse.org/repositories/OBS:/Server:/#{version}/images/#{qcow2_image['filename']}"
  options << " DISTRI=obs ARCH=x86_64 VERSION=#{version}"
  options << " BUILD=#{qcow2_image['build_id']} FLAVOR=Appliance"
  system('/usr/share/openqa/script/client', options)
end

trigger_run(version: 'Unstable')
trigger_run(version: '2.10')
