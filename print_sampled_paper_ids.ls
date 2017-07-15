require! {
  jsonfile
}

data = jsonfile.readFileSync '20_sampled_by_quartile.json'
paper_ids = data.map (.ID)
paper_ids.sort()
for paper_id in paper_ids
  console.log paper_id
