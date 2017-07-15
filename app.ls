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

kapp = new koa()
app = new koa-router()


compute_hash = (str) ->
  return crypto.createHash('sha256').update(str).digest('hex').substr(0, 32)

hash_to_filename = {}
filename_to_hash = {}
for filepath in glob.sync('papers/*.pdf')
  filename_base = filepath.replace(/^papers\//, '').replace(/\.pdf$/, '')
  console.log filename_base
  hashed = compute_hash(filename_base) + '.pdf'
  console.log hashed
  #hash_to_filename['']
  hash_to_filename[hashed] = filename_base + '.pdf'

app.get '/', (ctx) ->>
  ctx.body = 'hello world'
  return

kapp.use app.routes()
kapp.use app.allowedMethods()

port = process.env.PORT ? 5000

kapp.listen(port)
console.log "listening to port #{port} visit http://localhost:#{port}"

