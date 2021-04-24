# Cypress.io: Don't Forget a Global baseUrl
Recently I've been writing tests in Cypress.io.   Cypress is an excellent framework for developing and writing E2E tests.  It's obvious that the developer experience is a high priority for the framework.  The documentation and API are excellent, it's easy to debug tests, and it makes it easy to develop reliable and performant tests.

## baseURL
When designing your test projects and folders, one thing to keep in mind is the baseUrl.  Cypress allows  you to set a baseUrl in your configuration when you start up the test suite.  This baseUrl is used as the root URL for all of the visit commands you execute in the test suite. 

There is some great documentation on the cypress site about the best practice of setting a global baseURL:
https://docs.cypress.io/guides/references/best-practices#Setting-a-global-baseUrl

## Why is it important to set a global baseURL?

- ### Avoid reload at test startup
  When the Cypress test runner starts, it will open the baseURL or localhost on a random port number.  On your first visit command it will switch to the url requested.  This causes an unnecessary reload when tests are started.

- ### Check app availability on startup
  An added bonus of setting a baseURL is that Cypress will try out the url when the test starts and immediately let you know if the application isn't available for testing.

- ### Relative Visits
  The baseURL can be set once for the test suite and then any visits that you make to the application you're testing can be done with relative links.  Since you can switch the baseUrl in the configuration on startup this means that you can switch between environments without lots of environment specific link settings.

- ### Relative Redirects

- ### Base URL for Session Storage

- ### Override for Mocha Blocks

