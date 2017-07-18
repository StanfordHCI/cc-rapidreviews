process.on 'unhandledRejection', (reason, p) ->
  throw new Error(reason)

require! {
  glob
  crypto
}

require! {
  koa
  'koa-router'
}

send = require 'koa-send'

kapp = new koa()
app = new koa-router()

compute_hash = (str) ->
  return crypto.createHash('sha256').update(str).digest('hex').substr(0, 32)

hash_to_filename = {}
filename_to_hash = {}
do ->
  for let filepath in glob.sync('papers/*.pdf')
    filename_base = filepath.replace(/^papers\//, '').replace(/\.pdf$/, '')
    filename_with_extension = filename_base + '.pdf'
    hashed = compute_hash(filename_base) + '.pdf'
    #hash_to_filename['']
    hash_to_filename[hashed] = filename_with_extension
    filename_to_hash[filename_with_extension] = hashed
    app.get ('/papers/' + hashed), (ctx) ->>
      await send(ctx, 'papers/' + filename_base + '.pdf')
  for let filepath in glob.sync('www/**')
    filepath_base = filepath.replace(/^www\//, '')
    app.get ('/' + filepath_base), (ctx) ->>
      await send(ctx, filepath)

console.log filename_to_hash

app.get '/', (ctx) ->>
  ctx.body = 'hello world'
  return

kapp.use app.routes()
kapp.use app.allowedMethods()

port = process.env.PORT ? 5000

kapp.listen(port)
console.log "listening to port #{port} visit http://localhost:#{port}"

