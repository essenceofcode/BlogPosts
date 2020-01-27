## Troubleshooting CORS Issues in ASP.NET Web API 

> **Disclaimer:**  I am not an expert in configuring cross origin resource sharing.  CORS support is not a security feature.  Adding support for cross-origin resource sharing to your application decreases the overall security posture.  If your site will function correctly without enabling CORS functionality, you should leave the default settings to disable this support.  **You should make sure you thoroughly understand the implications of the CORS settings for your site or API before making any changes.**

Now that the disclaimer is out of the way...  I was recently working on an application and needed to enable CORS only when running in a development or test environment.  Thanks to the built-in middleware support for CORS in ASP.NET, this was a breeze.  Microsoft even has some very thorough documentation for setting up this middleware (https://docs.microsoft.com/en-us/aspnet/core/security/cors?view=aspnetcore-3.1).

However, even with this middleware in place I ran into some issues that I had to work through to get CORS support working.

In the context of a Web API, cross-origin resource sharing allows pages that were served from a FQDN that is different than the one serving your API to call your API.  This can be very useful in development situations where the port of your UI application may be different than your API.  It is also helpful when you need to allow sub-domains that you trust to make calls directly to your API.  

> **Pro Tip:**  The preferred way to have third-party sites call your API is **not** to allow CORS but instead to have the third-party’s web pages call their own server and have the server call your API.  This way there is no CORS constraints imposed by the browser.

Initially, I configured the middleware by defining a simply policy in my startup.cs ConfigureServices method:

```c#
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

You'll notice that you add this policy using a string array (there can be multiple allowed origins) and in this case a port.

And then adding the middleware:
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

Once this was done I thought CORS would be allowed between my test web server (hosting my JavaScript based UI) and the sub-domain I was hosting the API.  But I was wrong!

Troubleshooting I found the following issues that were preventing cross site requests in my environment: 

1. Needed methods and response headers were not allowed.
In order for CORS to function correctly you need to allow the server to return any requested headers.  There are a few that are returned by default, but if the client requests anything outside of this list then request will be denied by the server.  You also need to allow any HTTP methods you expect to be called (GET, POST, PUT, DELETE, OPTIONS).

Since I'm in a test environment that is internal to my organization, I went ahead and allowed all methods and all headers:

```c#
    services.AddCors(options =>
    {
        options.AddPolicy(AllowedOriginPolicy,
            builder =>
            {
                var corsOrigins = new String[1]{ "https://subdomain.test.example.com" };

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
                var corsOrigins = new String[1]{ "https://subdomain.test.example.com" };

                builder.WithOrigins(corsOrigins)
                    .AllowCredentials()
                    .AllowAnyHeader()
                    .AllowAnyMethod();;
            });
    });
```

3. Security appliance not allowing CORS.
4. XMLHttpRequest not sending credentials.

Hopefully one of these helps someone else find and resolve their CORS issue!