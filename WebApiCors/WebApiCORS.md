## Troubleshooting CORS Issues in ASP.NET Web API 

> **Disclaimer:  I am not an expert in configuring cross origin resource sharing (CORS).  This post is intended to be for learning purposes only and is not a guide to setting up CORS in a production environment. You should make sure you thoroughly understand the implications of the CORS settings for your site or API before making any changes.** 

This post shows how I was able to use CORS settings to allow for cross-origin requests in a development environment.  CORS is not allowed on the production domain where all requests are on the same FQDN.

Enabling CORS is not a security feature!  Adding exceptions for cross-origin resource sharing to your application decreases the overall security posture.  If your site will function correctly without enabling CORS support, you should leave it disabled.  

I was recently working on an application and needed to enable CORS when running in development and test environments.  Thanks to the built-in middleware support for CORS in ASP.NET, this was a breeze (much easier than earlier versions of .NET).  Microsoft even has thorough [documentation for setting up this middleware](https://docs.microsoft.com/en-us/aspnet/core/security/cors?view=aspnetcore-3.1).

However, even with this robust middleware in place, I ran into some issues that I had to work through to get CORS support fully functional.

In the context of REST based Web API, cross-origin resource sharing allows pages that were served from a UI that has a different FQDN to call the API.  This can be very useful in development situations where the port of your UI application may be different than your API.  It is also helpful when you need to allow sub-domains that you trust to make calls directly to your API.  

> **Pro Tip:**  The preferred way to have third-party sites call your API is **not** to allow CORS but instead to have the third-party’s web pages call their own server and have the server call your API.  This way there is no CORS constraints imposed by the browser.

Initially, I configured the middleware by defining a simply policy in my startup.cs ConfigureServices method:

```c#
private readonly string AllowedOriginPolicy = "_AllowedOriginPolicy";

public void ConfigureServices(IServiceCollection services)
{  
    services.AddCors(options =>
    {
        options.AddPolicy(AllowedOriginPolicy,
            builder =>
            {
                var corsOrigins = new String[1]{ "https://subdomain.test.example.com" };

                builder.WithOrigins(corsOrigins);
            });
    });

    services.AddControllers();
}
```

You'll notice that you add this policy creation is using a string array (there can be multiple allowed origins) and in this case a port.  The AllowedOriginPolicy is readonly string that identifies the policy.

And then adding the middleware based on this policy:
```c#
public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
{
    if (env.IsDevelopment())
    {
        app.UseDeveloperExceptionPage();
    }

    app.UseHttpsRedirection();

    app.UseRouting();

    app.UseCors(AllowedOriginPolicy);

    app.UseEndpoints(endpoints =>
    {
        endpoints.MapControllers();
    });
}
```

Once this was done I thought CORS would be allowed between my local JavaScript based UI and API.  But I was wrong!

Troubleshooting I found the following issues that were preventing cross site requests in my local development environment: 

1. Needed methods and response headers were not allowed.
In order for CORS to function correctly you need to allow the server to return any requested headers.  There are a few that are returned by default, but if the client requests anything outside of this list then request will be denied by the server.  You also need to allow any HTTP methods you expect to be called (GET, POST, PUT, DELETE, OPTIONS).

Since I'm in a local development environment, I went ahead and allowed all methods and all headers:

```c#
services.AddCors(options =>
{
    options.AddPolicy(AllowedOriginPolicy,
        builder =>
        {
            var corsOrigins = new String[1]{ "https://localhost:1234" };

            builder.WithOrigins(corsOrigins)
                .AllowAnyHeader()
                .AllowAnyMethod();;
        });
});
```

2. Credential cookies were not allowed.
By default, and for the safety of the user and site, the browser does not allow credential cookies to be sent on a CORS request.  If your site uses authentication and the credential cookies need to be sent with the CORS request, it is necessary to enable this feature:

```c#
services.AddCors(options =>
{
    options.AddPolicy(AllowedOriginPolicy,
        builder =>
        {
            var corsOrigins = new String[1]{ "https://localhost:1234" };

            builder.WithOrigins(corsOrigins)
                .AllowCredentials()
                .AllowAnyHeader()
                .AllowAnyMethod();;
        });
});
```

3. Fetch API not sending credentials.
By default the Browser Fetch API will not send credentials to a different origin.  In this case we had a web application using the Fetch API to send local REST requests to the ASP.NET Core Web API running on a different port.  The browser was not sending the credentials used by the web application to the Web API.  The reason for this was the default behavior of the Fetch API.

To allow Fetch to send the credentials cookie we added the credentials option:

```javascript
const response = await fetch(url, { credentials: 'include' });
```

This tells the fetch request to include the credential cookies even if the browser is making a cross-origin request.

MDN has great documentation on [Using Fetch](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch).

I hope one of these tips helps you with a problem you were encountering with CORS.