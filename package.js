Package.describe({
  name: 'pierreeric:fview-rwdsimplemenu',
  summary: 'Simple responsive menu plugin for famous-views',
  version: '0.2.0',
  git: 'https://github.com/PEM--/fview-rwdsimplemenu.git'
});

Package.onUse(function(api) {
  api.versionsFrom('1.0');
  // Both famo.us packages generally used in the Meteor community are
  // included as weak references.
  api.use('mjn:famous@0.3.1_2', 'client', { weak: true });
  api.use('raix:famono@0.9.19', { weak: true });
  // famous-views is integrated a mandatory reference.
  api.use([
    'coffeescript',
    'blaze',
    'templating',
    'tracker',
    'underscore',
    'iron:router@1.0.3',
    'gadicohen:famous-views@0.1.29',
    'gadicohen:reactive-window@1.0.1',
    'fortawesome:fontawesome@4.2.0_2',
    'pierreeric:cssc@1.0.3',
    'pierreeric:cssc-normalize@1.0.1',
    'pierreeric:cssc-famous@1.0.2',
    'pierreeric:cssc-colors@1.0.3'
  ], 'client');
  api.addFiles([
    'fview-rwdsimplemenu.coffee',
    'private_classes/hamburger.coffee',
    'private_classes/main_menu.coffee',
    'private_classes/top_menu.coffee',
    'private_classes/side_menu.coffee',
  ], 'client');
});
