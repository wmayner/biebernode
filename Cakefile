# ## DEPENDENCIES ##
#
# Prefixing CSS requires cssprefixer to be installed.
# run `easy_install cssutils` to install it.
#
# The other dependencies can be managed with npm.
# Toss this in your package.json:
#
# "devDependencies": {
#     "coffee-script": "*"
#   , "docco-husky": "*"
#   , "watchr": "*"
#   , "path": "*"
#   , "less": "*"
#   , "wrench": "*"
#   , "supervisor": "*"
#   , "colors": "*"
# }

{print}       = require 'util'
{spawn, exec} = require 'child_process'
watchr        = require 'watchr'
path          = require 'path'
wrench        = require 'wrench'
colors        = require 'colors'
colors.setTheme {
  verbose  : 'black'
, debug    : 'blue'
, error    : 'red'
, warn     : 'yellow'
, info     : 'green'
, emph     : 'inverse'
, underline: 'underline'
, data     : 'blue'
}

#########
# Paths #
########################################

srcDir    = 'src'
staticDir = 'public'
appFile   = path.join(srcDir,'app.coffee')
coffeeDir = path.join(srcDir,'js')
lessDir   = path.join(srcDir,'less')
cssDir    = path.join(staticDir,'css')
imgDir    = path.join(staticDir,'img')
jsDir     = path.join(staticDir,'js')
viewDir   = 'views'

###########
# Helpers #
########################################

# Fancy log alias
log = (message, styles, callback) ->
  if styles?
    for style in styles
      message = message[style]
  console.log message
  callback?()

execute = (cmd, options, callback) ->
  command = spawn cmd, options
  command.stdout.pipe process.stdout
  command.stderr.pipe process.stderr
  command.on 'exit', (status) -> callback?() if status is 0

lessc = (callback) ->
  console.log ''
  files = wrench.readdirSyncRecursive(lessDir)
  files = (path.join(lessDir,file) for file in files when /\.less/.test file)
  for file in files
    outputFile = file.split(path.extname(file))[0]+'.css'
    execute "lessc",
            [file, outputFile],
            log "compiled #{file} to #{outputFile}", ['data']
  log "  Compiled .less in #{lessDir}", ['info'], (callback if callback?)

prefixer = (callback) ->
  console.log ''
  files = wrench.readdirSyncRecursive(lessDir)
  files = (path.join(lessDir,file) for file in files when /\.css/.test file)
  counter = files.length
  for file in files
    counter = --counter
    outputFile = path.join(cssDir,path.basename(file))
    exec "cssprefixer #{file} > #{outputFile} --minify --debug",
     (err, stdout, stderr) ->
       if err then throw err
       else
         log "prefixed #{file} to #{outputFile}", ['data']
         if counter is 0
           log "  Prefixed .css files in #{lessDir} into #{cssDir}",
               ['info'],
               callback if callback?

# Compile coffee
coffee = (callback) ->
  console.log ''
  # compile app
  execute 'coffee',
          ['-l', '-b', '-o', '.', '-c', appFile],
          log "compiled #{appFile} to ./", ['data']
  # compile js
  files = wrench.readdirSyncRecursive(coffeeDir)
  files = (path.join(coffeeDir,file) for file in files when /\.coffee$/.test file)
  for file in files
    execute 'coffee',
            ['-l', '-b', '-o', jsDir, '-c', file],
            log "compiled #{file} to #{jsDir}", ['data']
  log "  Compiled .coffee files in #{coffeeDir} to #{jsDir} and #{appFile} to ./",
      ['info'],
      (callback if callback?)

docco = (callback) ->
  files = wrench.readdirSyncRecursive(coffeeDir)
  files = (path.join(coffeeDir,file) for file in files when /\.coffee$/.test file)
  console.log "\x1b[34m"
  execute 'docco-husky',
          files, ->
            log "  Generated project documentation ", ['info']
            callback?()

build = (callback) ->
  log ' Building project... ', ['info', 'emph']
  coffee ->
    lessc ->
      prefixer ->
        docco ->
          log '\n ...project built. ', ['info', 'emph'],
            (callback if callback?)

#########
# Tasks #
########################################

task 'build', 'Build the project', ->
  build()

task 'coffee', "Compile .coffee files in #{srcDir}", ->
  coffee()

task 'lessc', "Compile and prefix less in #{lessDir}", ->
  lessc -> prefixer()

task 'prefix', "Prefix less in #{lessDir}", ->
  prefixer()

task 'docs', 'Generate annotated source code with Docco', ->
  docco()

task 'dev', 'Start development environment', ->
  # initial build
  build ->
    # Watch source
    watchr.watch {
      path: srcDir
    , listeners: {
        log:
          (logLevel) ->
            # console.log 'watchr log: '.data, arguments
      , error:
          (err) -> log "watchr error: #{err}", ['error']
      , watching: 
          (err, watcherInstance, isWatching) ->
            if (err)
              log "Failed to watch #{watcherInstance.path} with error:", ['error']
              log err, ['error']
            else
              log "\n  Watching files in #{watcherInstance.path}  ", ['data', 'emph']
      , change:
          (changeType, filePath, fileCurrentStat, filePreviousStat) -> 
            if changeType is 'create'
              switch path.extname(filePath)
                when '.coffee' 
                  invoke 'docs'
                  invoke 'coffee'
                when '.less' then invoke 'lessc'
      }
    }
    # auto restart node with supervisor
    supervisor = spawn 'node', [
      './node_modules/supervisor/lib/cli-wrapper.js'
    , '-w'
    , viewDir+','+staticDir
    , '-i'
    , cssDir
    , '-e'
    , 'js|jade|json'
    , '-n'
    , 'error'
    , 'app'
    ]
    supervisor.stdout.pipe process.stdout
    supervisor.stderr.pipe process.stderr
