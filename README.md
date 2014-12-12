# fview-rwdsimplemenu: Simple responsive menu
A plugin for [famous-views](http://famous-views.meteor.com).

This plugin brings a responsive one level deep menu

**demo**: [Market analysis](http://marketanalysis.meteor.com/).

:warning: Work in progress :warning:

## Usage
Starts with the usual and add some packages:
```bash
meteor create myApp
cd myApp
mkdir client
meteor add gadicohen:famous-views pierreeric:fview-rwdsimplemenu
# From here you can choose your favorite Famo.us provider, mine is Raix's one.
meteor add raix:famono
```

You can choose to write your HTML templates with Blaze or
with [Maxime Quandalle's Jade](https://github.com/mquandalle/meteor-jade).
```bash
meteor add mquandalle:jade
```

Put your own logo
```jade
template(name='menuLogo')
  p: i.fa.fa-area-chart
```

Instantiate a menu and set menu entries with routes:
```coffee
@mainMenu = new RwdSimpleMenu
mainMenu.addRoute 'signin', 'fa-sign-in', ' Sign in'
mainMenu.addRoute 'signout', 'fa-sign-out', ' Sign out'
mainMenu.addRoute 'profile', 'fa-user', ' Profile'
mainMenu.addRoute 'company', 'fa-building', ' Company'
```

TODO: Carry on docs
