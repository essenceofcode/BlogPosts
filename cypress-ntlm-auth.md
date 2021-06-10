# Resetting cypress-ntlm-auth

> ## TLDR; Be sure to only run cy.ntlmReset() after all requests in a test are completed.

Recently we started to experience intermittent 401 errors when our Cypress tests were executing on our build server.  These errors were intermittent because they were timing dependent.  

We've been using a library with Cypress that allows it to authenticate with services protected by Windows authentication named [cypress-ntlm-auth](https://www.npmjs.com/package/cypress-ntlm-auth).  This package uses a proxy to allow you to handle NTLM authentication requests and it has worked well for us.

However, as our test suite grew, we started to notice random NTLM 401 Unauthorized responses.  After some research, we realized that this was because we were resetting the NTLM proxy on each request.  Right before each cy.visit(url) command we were resetting the proxy and adding the base url to the ntlm proxy table for the given request.  Something like:

```javascript
    cy.ntlmReset();
    cy.ntlm(url, user, password, domain);
    cy.visit(url);
```

This worked fine if the call was fairly quick and the page loaded didn't have any additional XHR asynchronous requests.  If the original call contained it did and there was another visit call quickly following the first call, it was possible that the ntlm proxy route table was cleared before the asynchronous request completed.  Even if the page was from the same base URL as the original request, if it's base url was cleared from the proxy then it would not negotiate the NTLM connection.  Causing the generation of a 401 Unauthorized response.

To make it even trickier, unless there is an assertion that causes Cypress to wait, it's even possible that this issue could span tests.  A request from a previous test could even generate a 401 response during the next test.  This makes things very confusing to debug.

> Safety tip:  Follow the Cypress best practice of using an intercept to ensure that asynchronous requests have completed before continuing.
```javascript
cy.intercept('GET', '/url').as('myRequest')
cy.get('#button').click()
cy.wait('@myRequest') 
```

To resolve this issue, we ended up putting the entire ntlm setup in our /support/index.js setup file:

```javascript
import './commands'
import 'cypress-ntlm-auth/dist/commands';

before('Initialize', () => {
  cy.ntlmReset();

  cy.ntlm(urlOne, user, password, domain);
  cy.ntlm(urlTwo, user, password, domain);
});
```

This Jasmine event then runs only one time before the entire test suite. So we set up the NTLM proxy and all of the routes it should respond to once in the initial test suite setup.  This seemed to work very well and ended the intermittent 401 Unauthorized errors.  Yay!