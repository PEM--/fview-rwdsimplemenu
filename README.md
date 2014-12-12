# fview-rwdsimplemenu: Simple responsive menu
A plugin for [famous-views](http://famous-views.meteor.com).

This plugin brings a responsive one level deep menu.

![fview-rwdsimplemenu](https://raw.githubusercontent.com/PEM--/fview-rwdsimplemenu/master/assets/fview-rwdsimplemenu.gif)

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

Add the menu to your main layout:
```jade
head
  title My super app
  meta(charset='utf-8')
  meta(name='viewport', content='width=device-width, maximum-scale=1, initial-scale=1, user-scalable=no')
  meta(name='apple-mobile-web-app-capable', content='yes')
  meta(name='apple-mobile-web-app-status-bar-style', content='black')
  meta(name='apple-mobile-web-app-capable', content='yes')
  meta(name='mobile-web-app-capable', content='yes')
body

template(name='layout')
  +famousContext id='mainCtx'
    // This add the sidemenu for mobile or xsmall screen
    +sideMenu
    +StateModifier align='[.5,.5]' origin='[.5,.5]' size=main
      +HeaderFooterLayout headerSize='50' footerSize='0'
        +StateModifier align='[.5,.5]' origin='[.5,.5]' target='header' translate='[0, 0, 100]'
            // This add the sidemenu for tablet or desktop
            +menu
        +RenderController target='content'
          +yield
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

TODO: Carry on docs (styling, API, ...)
