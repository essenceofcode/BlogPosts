# Cypress.io: Don't Forget a Global baseUrl

> TLDR; To help make your tests more reliable and prevent unexpected issues, organize Cypress tests around a single FQDN and don't switch between different target URLs during a test execution.  

## Cypress Journey
Recently I've been spending some time improving an existing test suite and writing tests in Cypress.io.   Cypress is an excellent framework for developing and writing E2E tests.  It's obvious that the developer experience is a high priority for their framework.  The documentation and API are excellent.  The framework makes it easy to debug and write reliable and performant tests.

## baseURL
When designing your test projects and folders, one thing to keep in mind is the baseUrl.  Cypress allows  you to set a baseUrl in your test suite configuration.  This baseUrl is used as the root URL for all of the visit commands you execute in the test suite. Setting a baseUrl is a Cypress recommended best practice:

[https://docs.cypress.io/guides/references/best-practices#Setting-a-global-baseUrl](https://docs.cypress.io/guides/references/best-practices#Setting-a-global-baseUrl)

## Why is it important to set a global baseURL?

- ### Avoid reload on startup
  When the Cypress test runner starts, it will open the baseURL or localhost on a random port number.  On your first visit command it will switch to the URL requested.  Without a global baseUrl defined, this will cause an unnecessary reload when tests are started.

- ### Check app availability on startup
  An added bonus of setting a baseURL is that Cypress will try out the url when the test starts and immediately let you know if the application isn't available for testing.

- ### Relative Visits
  The baseURL can be set once for the test suite and then any visits that you make to the application you're testing can be done with relative links.  Since you can switch the baseUrl in the configuration on startup this means that you can target different environments without lots of environment specific link settings.

- ### Relative Redirects
  If your application returns a relative redirect which causes a new URL to be opened, the baseURL is used to derive the relative address.  This is true if the baseUrl is present.  If it's not set then the last page visited is used.  

- ### Session Storage
  Cypress clears cookies and localStorage between tests, but it does not clear session storage.  If your application is using session storage and you need to clear it for a test, then you would need to clear it as part of your setup.  When you run the window.sessionStorage.clear() it applies to the origin of the current window which is the baseUrl.   

## Overriding baseUrl in Tests
You can set the baseUrl in the configuration, environment variables, or from the command line for the entire test suite.  However, it's not possible to switch this setting during a test run.  You can override the value for a describe or it block by passing it in as an option:

```javascript
it('Pass this test', { baseUrl: 'https://example.com' }, () => {
  // Test
});
```

This is great because it changes the baseUrl for the context of the test or describe block.  Although this works for the visit command, it does not work for relative redirects or clearing of session storage.  The local override does not appear to override the windows origin location which is set to the baseUrl at startup.

## Conclusion: Organize Tests around an FQDN
If you have multiple applications with different FQDNs that you would like to test, then you should organize your Cypress test folder structure around those different applications.  This allows the test execution for a particular application (FQDN) to target a single baseUrl. This allows the baseUrl to work intuitively for all of the contexts listed above and helps avoid unexpected behavior during testing.

One convenient way to organize tests by their baseUrl would be to use multiple nested Cypress projects as shown in this example:
[https://github.com/cypress-io/cypress-test-nested-projects](https://github.com/cypress-io/cypress-test-nested-projects)
