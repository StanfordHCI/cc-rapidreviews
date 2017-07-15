require! {
  fs
  csvjson
  pandemonium
  jsonfile
}

data_text = fs.readFileSync 'CC-papers-decisions.csv', 'utf-8'
csv_parse_options = {
  delimiter : ','
  quote     : '"'
}
data = csvjson.toObject(data_text, csv_parse_options)
data.sort (a, b) ->
  return a['Raw Score'] - b['Raw Score']
quartiles = [data[0 til Math.floor(data.length/4)], data[Math.floor(data.length/4) til Math.floor(data.length/2)], data[Math.floor(data.length/2) til Math.floor(data.length*3/4)], data[Math.floor(data.length*3/4) to]]
output = []
for quartile in quartiles
  samples = pandemonium.sample 5, quartile
  for sample in samples
    output.push sample
    console.log sample['ID']
jsonfile.writeFileSync('20_sampled_by_quartile.json', output)