Template.tips.events
  'click .tips-index':()->
    window.location = 'http://sj.qq.com/myapp/detail.htm?apkName=org.storebbs.together'
  'click .change-lang':()->
    if Session.equals('display-lang','en')
      TAPi18n.setLanguage('zh')
      Session.set('display-lang','zh')
    else
      TAPi18n.setLanguage('en')
      Session.set('display-lang','en')

Template.tips.rendered = ->
  Session.setDefault("display-lang",getUserLanguage())
  
Template.tips.helpers
  English:()->
    if Session.equals("display-lang",undefined)
      getUserLanguage() is 'en'
    else
      Session.equals("display-lang",'en')