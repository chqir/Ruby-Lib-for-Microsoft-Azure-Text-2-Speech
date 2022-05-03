#!/usr/bin/env ruby
require 'net/http'
require 'net/https'
require 'uri'
require 'json'
require 'ruby_speech'

class TTSnow

  def initialize
    #please store this in an env variable, and not in plaintext
    apiKey = "<put your api key here>"
    post_data = ""
    
    #settings for http
    url = URI.parse("https://<your reigion>.api.cognitive.microsoft.com/sts/v1.0/issueToken")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    headers = {
      'Ocp-Apim-Subscription-Key' => apiKey
    }

    # get the access token
    puts "get the Access Token"
    resp = http.post(url.path, post_data, headers)
    puts "Access Token: ", resp.body, "\n"

    $accessToken = resp.body
  end

  def speaks(text)
    #more http settings
    ttsServiceUri = "https://<your reigion>.tts.speech.microsoft.com/cognitiveservices/v1"
    url = URI.parse(ttsServiceUri)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    #set headers
    headers = {
      'content-type' => 'application/ssml+xml',
      'X-Microsoft-OutputFormat' => 'audio-16khz-128kbitrate-mono-mp3',
      'Authorization' => 'Bearer ' + $accessToken,
      'User-Agent' => 'TTSRuby'
    }                               


    # this is the request made to the azure tts api
    data = RubySpeech::SSML.draw do
      voice gender: :female, name: 'en-US-JennyNeural', language: 'en-US' do
        string text
      end
    end

    # get the wave data, which can literally just be written to a .wav file
    puts "getting the wave data"
    resp = http.post(url.path, data.to_s, headers)
    puts "wave data length: ", resp.body.length
    
    File.open("audio_output.wav", 'w+b') do |file|
        file.write(resp.body) # see also 'h'
    end
  
  end
end

#this is how to use the class
tts = TTSnow.new
tts.speaks("this is the string to speak")

