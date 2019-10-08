# Create an Angular Fake Service Layer with HttpInterceptor

When developing a client-side JavaScript application it can be really helpful to have a way to simulate server responses that would normally come from the web services supporting the application.  This post explains one way to create a fake XHR service layer for an Angular application.  The fake layer is enabled via the URL, making it very easy to enable and disable.

There are several different reasons why it is helpful to have a way to simulate responses from a backend web service:  
* **Prototyping** - Having a fake backend service layer allows you to begin work on the UI layer before the services are available.  Many projects have separate teams working on the service and client-side portions of the application.   Using a fake backend allows developers to proceed with UI development by creating a prototype out the service layer.
* **Local Development** - Having the full service layer, along with data storage, may not always be necessary for development work on the client-side application.  It can be very convenient to have a way to develop with a minimal service layer footprint.   
* **UI Testing** - Provides a fast and resilient way to enable testing of the user interface.  Since backend state and services do not need to be in place, the tests run much faster.  Also, the tests do not need to concerned about altering server side database state.  Because of this the tests are less brittle and more resilient. 


There are several options available for providing a fake backend service

* Create mock versions of data services
* Local JSON database - ex. [json-server](https://github.com/typicode/json-server#getting-started)
* HTTP Interceptor

All of these are acceptable options for working with your Angular application without the need for a full blown API.  I especially think that json-server is a great tool for prototyping.  However, for this post we're going to present a way to create a simple fake backend service based on HTTP Interceptor.  This approach works well because:

    * Allows specific and application appropriate responses
    * Easy to create and requires no additional NPM dependencies
    * Does not maintain state which means it will not cause side-effects that could affect testing
    * Easily runs on Continuous Integration Environments


## HTTP Interceptor
Angular's seam for allowing the inspection and response to all HTTP events.  It's pretty easy to implement, all that's needed is a class which implements the HttpInterceptor interface:

```javascript
import { HttpRequest, HttpHandler, HttpEvent, HttpInterceptor } from '@angular/common/http';
import { Observable } from 'rxjs';

export class FakeXHRInterceptor implements HttpInterceptor {

  private enabled: boolean;

    intercept(request: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {

      console.log('FakeXHR handling request:' + request.url);

      return next.handle(request);
    }
}
```

You'll notice that the HttpInterceptor interface requires that we implement a method intercept.  This method will fire for every HttpClient call in the application passing in details about the request and the next handler.  This provides the opportunity to handle and provide a fake response or to allow the response to pass through to the real network call.

In the example method above, you will notice that we log a message to the console with the URL and then pass the request on to the next handler (which is the real http handler in this case).

## Enabling Dynamically


Use Feature Slices