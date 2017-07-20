require! {
  fs
  csvjson
  pandemonium
  jsonfile
  crypto
  underscore
  shuffled
}

prelude = require 'prelude-ls'

compute_hash = (str) ->
  return crypto.createHash('sha256').update(str).digest('hex').substr(0, 32)

data_text = fs.readFileSync 'cc_rapid_review_signups.csv', 'utf-8'
csv_parse_options = {
  delimiter : ','
  quote     : '"'
}
paper_data = jsonfile.readFileSync '20_sampled_by_quartile.json'
paper_ids = paper_data.map (.ID)
reviewer_data = csvjson.toObject(data_text, csv_parse_options)
reviewer_email_list = []
reviewer_email_to_paper_ids = {}
for reviewer_info in reviewer_data
  email = reviewer_info['电子邮件地址'] 
  reviewer_email_list.push email
  reviewer_email_to_paper_ids[email] = []
  #console.log email
reviewer_email_list = underscore.uniq reviewer_email_list
paper_id_list = []
paper_id_to_info = {}
for paper_info in paper_data
  new_paper_info = {}
  paper_id = paper_info['ID'].replace('CCfp', '')
  paper_id_list.push paper_id
  paper_basefilename_noext = 'p_0' + paper_id + '-paper_p1-p2'
  paper_basefilename = paper_basefilename_noext + '.pdf'
  paper_hashed = compute_hash paper_basefilename_noext
  paper_title = paper_info['Submission (94)']
  new_paper_info.filename = paper_basefilename
  new_paper_info.hashed = paper_hashed
  new_paper_info.paperid = paper_id
  new_paper_info.title = paper_title
  if not fs.existsSync('papers/' + paper_basefilename)
    console.log 'misssing file: ' + paper_basefilename
  paper_id_to_info[paper_id] = new_paper_info

#prev_available_reviewers = JSON.parse JSON.stringify reviewer_email_list
/*
get_available_reviewer_pool = (paper_id) ->
  available_reviewers = []
  for reviewer_email in reviewer_email_list # prev_available_reviewers
    if reviewer_email_to_paper_ids[reviewer_email].length >= 10
      continue
    if reviewer_email_to_paper_ids[reviewer_email].includes(paper_id)
      continue
    available_reviewers.push reviewer_email
  #prev_available_reviewers := JSON.parse JSON.stringify available_reviewers
  return JSON.parse JSON.stringify available_reviewers
*/

get_reviewer_with_fewest_assigned_who_has_not_reviewed_paper = (paper_id) ->
  num_reviewed_to_reviewers = {}
  for reviewer_email in shuffled(reviewer_email_list)
    if reviewer_email_to_paper_ids[reviewer_email].includes(paper_id)
      continue
    num_reviewed = reviewer_email_to_paper_ids[reviewer_email].length
    if not num_reviewed_to_reviewers[num_reviewed]?
      num_reviewed_to_reviewers[num_reviewed] = []
    num_reviewed_to_reviewers[num_reviewed].push reviewer_email
  min_num_reviewed = prelude.minimum(Object.keys(num_reviewed_to_reviewers).map(-> parseInt(it)))
  available_reviewers = num_reviewed_to_reviewers[min_num_reviewed]
  return available_reviewers[Math.floor(Math.random() * available_reviewers.length)]

/*
do ->
  for paper_id in paper_id_list
    for reviewer_num from 0 til 31
      reviewers = underscore.sample(get_available_reviewer_pool(paper_id), 1)
      for reviewer_email in reviewers
        reviewer_email_to_paper_ids[reviewer_email].push paper_id
*/
do ->
  for paper_id in paper_id_list
    for reviewer_num from 0 til 31
      reviewer_email = get_reviewer_with_fewest_assigned_who_has_not_reviewed_paper(paper_id)
      reviewer_email_to_paper_ids[reviewer_email].push paper_id
do ->
  for reviewer_email,paper_id_list of reviewer_email_to_paper_ids
    reviewer_email_to_paper_ids[reviewer_email] = shuffled(paper_id_list)

jsonfile.writeFileSync 'reviewer_email_list.json', reviewer_email_list
jsonfile.writeFileSync 'reviewer_email_to_paper_ids.json', reviewer_email_to_paper_ids
jsonfile.writeFileSync 'paper_id_to_info.json', paper_id_to_info
