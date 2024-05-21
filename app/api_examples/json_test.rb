require 'json'
file = File.read('output.json')
data_hash = JSON.parse(file)
p data_hash[0]['startMillis']
