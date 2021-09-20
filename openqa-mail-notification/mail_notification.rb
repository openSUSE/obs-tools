#!/usr/bin/ruby

require 'dotenv/load'
require 'net/https'
require 'net/smtp'
require 'uri'
require 'json'
require 'mail'
require 'yaml'
require 'faraday'
require 'logger'

@logger = Logger.new(STDOUT)
original_formatter = Logger::Formatter.new
@logger.formatter = proc { |severity, datetime, progname, msg|
  original_formatter.call(severity, datetime, progname, msg.dump)
}

FREQUENCY = ENV.fetch('OBS_TOOLS_RUN_EVERY', 10).to_i

# openQA settings
OPENQA_URL = ENV.fetch("OBS_TOOLS_OPENQA_URL") { "https://openqa.opensuse.org" }
DISTRIBUTION = ENV.fetch("OBS_TOOLS_OPENQA_DISTRIBUTION") { "obs" }
VERSIONS = ENV.fetch("OBS_TOOLS_OPENQA_VERSIONS") { "Unstable 62 2.10 63" }

# SMTP settings
FROM = ENV.fetch("OBS_TOOLS_FROM")
TO_SUCCESS = ENV.fetch("OBS_TOOLS_TO_SUCCESS")
TO_FAILED = ENV.fetch("OBS_TOOLS_TO_FAILED")
SMTP_SERVER = ENV.fetch("OBS_TOOLS_SMTP_SERVER")

def get_build_information(version, group)
  @logger.info("Gathering information for #{version}")
  response = Faraday.get("#{OPENQA_URL}/api/v1/jobs?distri=#{DISTRIBUTION}&version=#{version}&groupid=#{group}")
  unless response.status == 200
    @logger.warn("Could not fetch openQA jobs: #{response.status}")
    abort
  end
  JSON.parse(response.body)['jobs'].last
end

def modules_to_sentence(modules)
  modules.map { |m| "#{m['name']} #{m['result']}" }
end

def build_message(build, successful_modules, failed_modules, version, group)
  <<~MESSAGE_END
    See #{OPENQA_URL}tests/overview?distri=#{DISTRIBUTION}&version=#{version}&build=#{build}&groupid=#{group}

    #{failed_modules.length + successful_modules.length} modules, #{failed_modules.length} failed, #{successful_modules.length} successful

    Failed:
    #{failed_modules.join("\n")}

    Successful:
    #{successful_modules.join("\n")}
  MESSAGE_END
end

def send_notification(to, subject, message)
  begin
    mail = Mail.new do
      from    FROM
      to      to
      subject subject
      body    message
    end
    settings = { address: SMTP_SERVER, port: 25, enable_starttls_auto: false }
    settings[:domain] = ENV.fetch("HOSTNAME") if ENV.fetch('HOSTNAME', nil).empty?
    mail.delivery_method :smtp, settings
    mail.deliver
  rescue Exception => e
    @logger.warn("Could not send mail: #{e.inspect}")
    abort
  end
  @logger.info("Sent notification #{subject} to #{to}")
end

Hash[VERSIONS.split.each_slice(2).to_a].each_pair do |version, group|
  build = get_build_information(version, group)

  unless build['state'] == 'done'
    @logger.info("Build not done yet for #{version}...")
    next
  end

  last_build = DateTime.parse(build['t_finished'])
  frequency_minutes_ago = DateTime.now.new_offset(0) - (FREQUENCY / 1440.0)
  new_result = last_build >= frequency_minutes_ago

  unless new_result
    @logger.info("No new builds for #{version}...")
    next
  end

  modules = build['modules']
  successful_modules = modules.select { |m| m['result'] == 'passed' }
  failed_modules = modules.select { |m| m['result'] == 'failed' }
  successful_modules = modules_to_sentence(successful_modules)
  failed_modules = modules_to_sentence(failed_modules)
  subject = "Build #{build['result']} in openQA: #{build['name']}"
  message = build_message(build['settings']['BUILD'], successful_modules, failed_modules, version, group)
  to = TO_SUCCESS
  to = TO_FAILED unless failed_modules.empty?
  send_notification(to, subject, message)
end
