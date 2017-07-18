require! {
  fs
  csvjson
  jsonfile
  underscore
  querystring
}

reviewer_email_list = jsonfile.readFileSync 'reviewer_email_list.json'
reviewer_email_to_paper_ids = jsonfile.readFileSync 'reviewer_email_to_paper_ids.json'
paper_id_to_info = jsonfile.readFileSync 'paper_id_to_info.json'

output = []
for reviewer_email in reviewer_email_list
  reviewer_info = {}
  reviewer_info.email = reviewer_email
  for paper_id,idx in reviewer_email_to_paper_ids[reviewer_email]
    paper_info = paper_id_to_info[paper_id]
    reviewer_info['paper_title_' + idx] = paper_info.title
    reviewer_info['paper_link_' + idx] = 'https://rapidreviews.herokuapp.com/viewer.html?paperid=' + paper_info.hashed
    reviewer_info['form_link_' + idx] = 'https://docs.google.com/forms/d/e/1FAIpQLSdrDD_FfnpuENeowZiOqIoV6TPSPV8xAkZb8Y4_-2o3Q8lJ7g/viewform?' + querystring.stringify({
      'entry.131012394': reviewer_email,
      'entry.1020420589': paper_info.title,
    })
  output.push reviewer_info

options = {
  delimiter   : ",",
  wrap        : true,
  headers     : 'relative',
  arrayDenote : "",
}
console.log csvjson.toCSV output, options