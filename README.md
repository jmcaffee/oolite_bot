# oolite_bot

oolite_bot is a bot to run a trading route in Oolite.
It is written in bash, using xwd, ImageMagick, and sha256sum.

A 4-part series of articles was written discussing the process of creating oolite_bot.
The first article of the series can be found at [jeffmcaffee.com/creating-a-simple-bot](http://www.jeffmcaffee.com/creating-a-simple-bot/).

Please feel free to submit well written pull requests to improve these scripts.

## Need Help or Want to Contribute?

All contributions are welcome: ideas, patches, documentation, bug reports, and complaints.

Here are some basic guidelines if you'd like to contribute:

* Have an idea or a feature request? File a ticket on [github](https://github.com/jmcaffee/oolite_bot/issues).
* If you think you found a bug, it probably is a bug. File it on [github](https://github.com/jmcaffee/oolite_bot/issues).
* If you want to send patches, best way is to fork this repo and send me a pull request.

### Contributing by forking from GitHub

First, create a github account if you do not already have one.  Log in to
github and go to [the main oolite_bot github page](https://github.com/jmcaffee/oolite_bot).

At the top right, click on the button labeled "Fork".  This will put a forked
copy of the main oolite_bot repo into your account.  Next, clone your account's github
repo of oolite_bot.  For example:

    $ git clone git@github.com:yourusername/oolite_bot.git

Add the `oolite_bot/bin` directory to your path or create aliases to `oolite_bot/bin/bot`
and `oolite_bot/bin/bot-funcs.sh` from a directory that **is** on your path.

At this point, the `bot` command should run directly from the code in your cloned
repo.  Now simply make whatever changes you want, commit the code, and push
your commit back to master.

If you think your changes are ready to be merged back to the main oolite_bot repo, you
can generate a pull request on the github website for your repo and send it in
for review.
