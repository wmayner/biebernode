# ### Globals ###

# `setInterval` variable
bieberFeeder = 0
# Frequency of feed updates
feedSpeed = 5000
# String IDs of current Bieber tweets
currentTweets = []

# ### Generic AJAX GET request ###
request = (url, callback) ->
  # Create a request object
  req = new XMLHttpRequest()
  # Specify the HTTP method, URL, and asynchronous flag
  req.open 'GET', url, true
  # Add an event handler
  req.addEventListener('load', (e) ->
    # If request was successful,
    # pass the content of the request to the callback
    if req.status is 200
      console.log('** REQUEST SUCCEEDED **')
      callback?(req.responseText)
    else
      console.log 'something went wrong, check the request status'
  , false)
  # Start the request (with no POST)
  req.send null

# ### Deduper ###
# Remove tweets that are already in `currentTweets` and
# tweets that appear more than once in a single request
deduper = (tweets) ->
  batchIDs = []
  deduped = []
  for tweet in tweets
    if tweet.id_str in currentTweets then current = true
    if tweet.idstr in batchIDs then seen = true
    unless (tweet.id_str in currentTweets or tweet.id_str in batchIDs)
      deduped.push(tweet)
      batchIDs.push(tweet.id_str)
  return deduped

# ### I can has JSON pls? ###
getTweets = (callback) ->
  # Make a request to my feed
  request 'http://bieber.mattpatenaude.com/feed/wmayner',
    (tweetText) ->
      # Parse as JSON, remove duplicates, and pass it
      # to the callback
      callback(deduper(JSON.parse(tweetText)))

# ### Print-A-Tweet, any tweet ###
# Takes a tweet object and a display function, e.g.
# `(tweetElement) -> tweetElement.fadeIn()`
printTweet = (tweet, display) ->
  # Push its ID
  currentTweets.push(tweet.id_str)

  # Toss the tweet data into the `li`
  li = document.createElement('li')
  li.className = 'tweet'
  li.id = tweet.id_str
  # Hide the new tweet initially, so it can fade in
  li.style.display = "none"
  # Construct the tweet element (anchorizing the text)
  li.innerHTML = "
    <img class='tweet-img' src=#{tweet.user?.profile_image_url or ''}>
    <div class='tweet-content'>
      <div class='tweet-header-row'>
        <div class='tweet-name'>
          <a href='http://www.twitter.com/#{tweet.user.screen_name or ''}' target='_blank'>
            #{tweet.user?.name or ''}
          </a>
        </div>
        <div class='tweet-handle'>
          @#{tweet.user?.screen_name or ''}
        </div>
      </div>
      <div class='tweet-text-wrapper'>
        <div class='tweet-text'>
          #{anchorize(tweet)}
        </div>
      </div>
    </div>"
  # Insert into it the feed
  newTweet = $('#tweets')[0].insertBefore(li,
    $('#tweets')[0].firstChild)
  # Display it using the passed function
  display($('#'+tweet.id_str))

# ### Display a full stack of lovely Bieber tweets (Beets)###
populateFeed = (callback) ->
  getTweets (tweets) ->
    for tweet in tweets
      printTweet(tweet,
        (newTweet) -> newTweet.fadeIn("normal"))
    callback?()

# ### Update the feed ###
updateFeed = () ->
  console.log "** UPDATING FEED **"
  getTweets (tweets) ->
    # Print a tweet and remove the last one
    printTweet(tweets[0],
      (newTweet) -> newTweet.slideDown("normal"))
    # Remove last tweet from DOM and `currentTweets`
    lastTweet = $('.tweet').last()
    lastTweet.slideUp("normal", () -> $(this).remove())
    currentTweets.splice(currentTweets.indexOf(lastTweet.attr('id').toString()),1)

# ### Wait, please, make it stop... ###
# The event handler for the play/pause button.
feedControl = () =>
  control = $('#control')
  if control.hasClass('playing')
    stopFeed()
    console.log "** PAUSE FEED **"
    control.removeClass('playing')
    control.addClass('paused')
  else if control.hasClass('paused')
    # Update feed immediately on click
    updateFeed()
    # Start auto-updating
    startFeed()
    console.log "** PLAY FEED **"
    control.removeClass('paused')
    control.addClass('playing')

startFeed = () ->
  bieberFeeder = setInterval(updateFeed, feedSpeed)

stopFeed = () ->
  clearInterval(bieberFeeder)
  bieberFeeder = 0

# ## LIGHTS, CAMERA, BIEBERRRRRRRRR ##
$('document').ready () ->
  # Hide everything initially
  $('#container, footer').hide()
  # Fade-in everything after feed is populated
  populateFeed($('#container, footer').fadeIn(1500))
  # Start feed
  startFeed()
  # Press `p` to play/pause
  $('body').keydown (e) ->
    if e.which is 80
      feedControl()
      $('#control-info').fadeOut('normal')
  # Add feed-control click handler
  $('#control').click(feedControl)

# ### Anchorize ###
# Put anchors in the tweet text based on tweet entities
anchorize = (tweet) ->
  text = tweet.text

  # Quote a string for regex escaping
  quote = (str) ->
    return str.replace(/([.*+?^=!:${}()|[\]\/\\])/g, "\\$1")

  # Anchorize urls
  if tweet.entities.urls?
    for url in tweet.entities.urls
      re = RegExp(quote(url.url), 'g')
      text = text.replace(re,'<a href="'+url.expanded_url+'" target="_blank">'+url.display_url+'</a>')

  # Anchorize user mentions
  if tweet.entities.user_mentions?
    for userMention in tweet.entities.user_mentions
      re = RegExp(quote('@'+userMention.screen_name), 'g')
      text = text.replace(re,'<span class=screen-name>@<a href="http://twitter.com/'+userMention.screen_name+'" target="_blank">'+userMention.screen_name+'</a></span>')

  # Anchorize media
  if tweet.entities.media?
    for media in tweet.entities.media
      re = RegExp(quote(media.url), 'g')
      text = text.replace(re,'<a href="'+media.expanded_url+'" target="_blank">'+media.display_url+'</a>')

  # Anchorize hashtags
  if tweet.entities.hashtags?
    for hashtag in tweet.entities.hashtags
      re = RegExp(quote('#'+hashtag.text), 'g')
      text = text.replace(re,'<span class=hashtag>#<a href="http://twitter.com/search?q=%23'+hashtag.text+'" target="_blank">'+hashtag.text+'</a></span>')

  # Anchorize and truncate any remaining links
  re = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig
  text.replace re, (href) ->
    partial = href.length<10 ? href : href.substring(0,10)+"..."
    return "<a href='"+href+"' target='_blank'>"+
      partial+"</a>"

  return text
