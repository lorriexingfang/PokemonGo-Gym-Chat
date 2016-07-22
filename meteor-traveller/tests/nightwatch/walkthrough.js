// add tests to this file using the Nightwatch.js API
// http://nightwatchjs.org/api

module.exports = {
  "Basic Nightwatch Walkthrough" : function (client) {
    client
      .url("http://localhost:3000")
      .waitForElementVisible('body', 1000)
      .waitForElementVisible('div#wrap', 1000)
      .waitForElementVisible('div#footer', 1000)
      .waitForElementVisible('div.top', 1000)
      .waitForElementVisible('div.top div', 1000)
      .waitForElementVisible('.container', 1000)
      .waitForElementVisible('button#pub_board', 1000)
      .waitForElementVisible('button#partner', 1000)
      .waitForElementVisible('button#local_service', 1000)
      .waitForElementVisible('button#dashboard', 1000)

      .verify.containsText('div.homeMain div:nth-child(2)', '热门目的地')
      .verify.containsText('div.homeMain div:nth-child(2) div.hottop', '昆明')
      .verify.containsText('div.homeMain div:nth-child(4)', '热门景点')
      .verify.containsText('div.homeMain div:nth-child(6)', '热门目的地')
      .verify.containsText('div.homeMain div:nth-child(8)', '日光之城')

      .click('div.homeMain div:nth-child(2) div.hottop')
      .pause(1000)
      .waitForElementVisible('div#btn_back', 1000)
      .waitForElementVisible('button#add', 1000)

      .click('div#btn_back')
      .pause(1000)
      .waitForElementVisible('button#pub_board', 1000)
      .waitForElementVisible('button#partner', 1000)
      .waitForElementVisible('button#local_service', 1000)
      .waitForElementVisible('button#dashboard', 1000)

      .click('button#partner')
      .pause(1000)
      .waitForElementVisible('button#add', 1000)
      .waitForElementVisible('button#pub_board', 1000)
      .waitForElementVisible('button#partner', 1000)
      .waitForElementVisible('button#local_service', 1000)
      .waitForElementVisible('button#dashboard', 1000)

      .click('button#local_service')
      .pause(1000)
      .waitForElementVisible('button#pub_board', 1000)
      .waitForElementVisible('button#partner', 1000)
      .waitForElementVisible('button#local_service', 1000)
      .waitForElementVisible('button#dashboard', 1000)

      .click('button#dashboard')
      .pause(1000)
      .waitForElementVisible('button#pub_board', 1000)
      .waitForElementVisible('button#partner', 1000)
      .waitForElementVisible('button#local_service', 1000)
      .waitForElementVisible('button#dashboard', 1000)

      .click('button#pub_board')
      .pause(1000)
      .waitForElementVisible('button#pub_board', 1000)
      .waitForElementVisible('button#partner', 1000)
      .waitForElementVisible('button#local_service', 1000)
      .waitForElementVisible('button#dashboard', 1000)

      .click('button#partner')
      .pause(1000)
      .waitForElementVisible('button#add', 1000)
      .waitForElementVisible('button#pub_board', 1000)
      .waitForElementVisible('button#partner', 1000)
      .waitForElementVisible('button#local_service', 1000)
      .waitForElementVisible('button#dashboard', 1000)

      .click('button#local_service')
      .pause(1000)
      .waitForElementVisible('button#pub_board', 1000)
      .waitForElementVisible('button#partner', 1000)
      .waitForElementVisible('button#local_service', 1000)
      .waitForElementVisible('button#dashboard', 1000)

      .click('button#dashboard')
      .pause(1000)
      .waitForElementVisible('button#pub_board', 1000)
      .waitForElementVisible('button#partner', 1000)
      .waitForElementVisible('button#local_service', 1000)
      .waitForElementVisible('button#dashboard', 1000)

      .click('button#pub_board')
      .pause(1000)
      .waitForElementVisible('button#pub_board', 1000)
      .waitForElementVisible('button#partner', 1000)
      .waitForElementVisible('button#local_service', 1000)
      .waitForElementVisible('button#dashboard', 1000)

      .end();

  }
};
