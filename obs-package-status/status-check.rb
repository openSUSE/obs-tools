#!/usr/bin/ruby
require 'net/http'
require 'nokogiri'
require 'json'

def config_get(key)
  path = File.expand_path(File.dirname(__FILE__)) + "/config"
  if !File.exists?(path)
    $stderr.puts "Please adapt the config file first. It got generated in the directory of the script."

    config_template = "obs_user=
obs_password=
obs_project_link=
repos=
trello_api_key=
trello_api_token=
trello_card_id=
trello_cover_success_name=
trello_cover_error_name="

    File.open(path, "w").write(config_template)
    exit! 1
  end

  File.open(path).each_line do |line|
    pos = line.index('=')
    if pos != -1 && line[0..pos-1] == key
      value = line[pos+1..-1]
      value = value[0..value.length-2] if value[-1] == "\n"

      return value
    end
  end

  nil
end

# Get status of building
api_uri = URI("https://api.opensuse.org/build/OBS:Server:Unstable/_result?multibuild=1&locallink=1&package=obs-server")
request = Net::HTTP::Get.new(api_uri)
request.basic_auth config_get('obs_user'), config_get('obs_password')
response = Net::HTTP.start(api_uri.hostname, api_uri.port, use_ssl: true) { |http| http.request(request) }

# Parse XML from OBS
status_list = []
Nokogiri::XML(response.body).xpath('//resultlist/result').each do |result|
  code = result.xpath("./status").map {|element| element.attributes["code"].value if element.attributes["package"].value == "obs-server" }.first
  if code == "disabled"
    next
  end

  status_list.push({
    code:       code,
    repository: result.attributes["repository"].value,
    arch:       result.attributes["arch"].value
  })
end

#Calculate repositories to check from config
repos = []
config_get("repos").split(",").each do |repo|
  data = repo.split(":")
  repos.push({ repository: data[0], arch: data[1] })
end

package_successfully_built = true
skip_cover_update = false

trello_card_content = "Visit project: #{config_get("obs_project_link")}\n\n"
trello_card_content += "Last status scan: #{Time.now}\n\n"

# Check the status of each repository
repos.each do |repo|
  status_list.each do |item|
    if item[:repository] == repo[:repository] && item[:arch] == repo[:arch]
      trello_card_content += "#{repo[:repository]} (#{repo[:arch]}): #{item[:code]}\n"

      if item[:code] == "scheduled" || item[:code] == "building"
        # don't update trello card cover if one of the packages is being built
        skip_cover_update = true
      end

      if item[:code] == "unresolvable" || item[:code] == "failed"
        package_successfully_built = false
      end
    end
  end
end

trello_card_id = config_get("trello_card_id")
trello_key = config_get("trello_api_key")
trello_token = config_get("trello_api_token")
credentials_query = "key=#{trello_key}&token=#{trello_token}"

# Update the card cover and comments if needed
unless skip_cover_update
  cover_file_name = package_successfully_built ? config_get("trello_cover_success_name") : config_get("trello_cover_error_name")

  # Get the attachments in the card
  attachment_uri = URI("https://api.trello.com/1/cards/#{trello_card_id}/attachments?#{credentials_query}")
  response = Net::HTTP.start(attachment_uri.hostname, attachment_uri.port, use_ssl: true) { |http| http.request(Net::HTTP::Get.new(attachment_uri)) }
  attachments = JSON.parse(response.body)
  cover_id = attachments.select { |image| image["name"] == cover_file_name }.first["id"]

  # Update the cover
  cover_uri = URI("https://api.trello.com/1/cards/#{trello_card_id}/idAttachmentCover?value=#{cover_id}&#{credentials_query}")
  Net::HTTP.start(cover_uri.hostname, cover_uri.port, use_ssl: true) { |http| http.request(Net::HTTP::Put.new(cover_uri)) }

  # Get all the comments in the card
  comments_uri = URI("https://api.trello.com/1/cards/#{trello_card_id}/actions?filter=commentCard&#{credentials_query}")
  response = Net::HTTP.start(comments_uri.hostname, comments_uri.port, use_ssl: true) { |http| http.request(Net::HTTP::Get.new(comments_uri)) }
  comments = JSON.parse(response.body)

  status_regexp = package_successfully_built ? /Passed/ : /Failed/
  status_changed = comments.any? && (comments.first["data"]["text"] =~ status_regexp).nil?
  status_changed_to_failed = !package_successfully_built && status_changed

  # Remove the comments
  if status_changed
    comments.each do |comment|
      remove_comment_uri = URI("https://api.trello.com/1/cards/#{trello_card_id}/actions/#{comment["id"]}/comments?#{credentials_query}")
      Net::HTTP.start(remove_comment_uri.hostname, remove_comment_uri.port, use_ssl: true) { |http| http.request(Net::HTTP::Delete.new(remove_comment_uri)) }
    end
  end

  # Add the comment
  if comments.empty? || status_changed
    notify_to_board = status_changed_to_failed ? "@board" : ""
    status_text = package_successfully_built ? "**Passed** :smiley: " : "**Failed** :sob:"
    comment_text = "#{notify_to_board} the build has #{status_text}"
    new_comment_uri = URI(URI.escape("https://api.trello.com/1/cards/#{trello_card_id}/actions/comments?text=#{comment_text}&#{credentials_query}"))
    Net::HTTP.start(new_comment_uri.hostname, new_comment_uri.port, use_ssl: true) { |http| http.request(Net::HTTP::Post.new(new_comment_uri)) }
  end
end

# Update description and content of the card always
card_desc_uri = URI("https://api.trello.com/1/cards/#{trello_card_id}/desc?#{credentials_query}")
request = Net::HTTP::Put.new(card_desc_uri)
request.set_form_data({
  "value" => trello_card_content
})
Net::HTTP.start(card_desc_uri.hostname, card_desc_uri.port, use_ssl: true) { |http| http.request(request) }
