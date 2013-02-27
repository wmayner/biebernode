BIEBERNODE
==========

**"The Game"**: see how many Bieber tweets you can read without hitting the pause button or vomiting.

## WTF?

This is, beliebe it or not, an assignment for a class (cs132: Creating Modern Web Apps). We were given a server that spits out a JSON of bieber-related tweets, and the task is to display them in a feed using javascript.

Note: the server is hosted by a course TA, so I'm not sure how long it'll actually be up.

## Development

Run `cake` to see the tasks defined in the cakefile.

`cake dev` is the most important one - it builds the project, starts the server on localhost:3000, and watches everything for any changes (upon which it restarts the server). It doesn't watch CSS, actually, because I'm using LiveReload to update CSS without a page refresh.

## Features
* One new tweet is displayed every few seconds at the top
* Pause/play button on top left of feed (click or press `p` to use it)
* Hilarious video of the Biebz puking his brains out in front of thousands of people

P.S. - The best Bieber-related tweet is from Bieber himself: **"Milk was a bad choice. Lol"**

## Bugs
* Emoji characters are not displayed properly (these appear as boxes with an `X` in them, at least when running Chrome on my machine).
* If the play/pause button is pressed too quickly, you may see duplicate tweets.

## Technologies
* jQuery
* normalize.css
* CoffeeScript for the JS (in `src/js`)
* Less for the CSS (in `src/less`)
* Jade for the HTML
