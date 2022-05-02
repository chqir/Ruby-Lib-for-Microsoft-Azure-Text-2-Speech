#!/usr/bin/env ruby
require 'net/http'
require 'net/https'
require 'uri'
require 'json'
require 'ruby_speech'

class TTSnow
  def initialize
    apiKey = "<put your api key here>"
    post_data = ""

    url = URI.parse("https://<your reigion>.api.cognitive.microsoft.com/sts/v1.0/issueToken")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    headers = {
      'Ocp-Apim-Subscription-Key' => apiKey
    }

    # get the Access Token
    puts "get the Access Token"
    resp = http.post(url.path, post_data, headers)
    puts "Access Token: ", resp.body, "\n"

    $accessToken = resp.body
  end

  def speaks(text, num, subnum)
    ttsServiceUri = "https://<your reigion>.tts.speech.microsoft.com/cognitiveservices/v1"
    url = URI.parse(ttsServiceUri)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    headers = {
      'content-type' => 'application/ssml+xml',
      'X-Microsoft-OutputFormat' => 'audio-16khz-128kbitrate-mono-mp3',
      'Authorization' => 'Bearer ' + $accessToken,
      'User-Agent' => 'TTSRuby'
    }                               


    # SsmlTemplate = "<speak version='1.0' xml:lang='en-us'><voice xml:lang='%s' xml:gender='%s' name='%s'>%s</voice></speak>"
    data = RubySpeech::SSML.draw do
    # Use short name for ''Microsoft Server Speech Text to Speech Voice (en-US, Guy24KRUS)'
      voice gender: :female, name: 'en-US-JennyNeural', language: 'en-US' do
        string text
      end
    end
    # get the wave data
    puts "get the wave data"
    resp = http.post(url.path, data.to_s, headers)

    puts "wave data length: ", resp.body.length

    File.open("audio_output.wav", 'w+b') do |file|
        file.write(resp.body) # see also 'h'
    end
  
  end
end
