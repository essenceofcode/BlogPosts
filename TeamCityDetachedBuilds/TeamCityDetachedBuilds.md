# Using TeamCity Detached Builds to Invoke AWS Services

> TLDR; Use TeamCity detached builds to provide a more seamless integration between TeamCity and AWS CodeDeploy.

## Asynchronous External Service
One of the challenges with invoking a process in AWS from TeamCity is that the call to AWS is usually asynchronous. An example of when you might want to do this is to make CloudFormation updates or initiate a deployment using CodeDeploy. Unlike most build tasks executed in TeamCity, the AWS call returns as soon as the message is received. It does not block until the deployment is complete. This is good because it doesn’t consume an agent while waiting, but bad because there is no indication in TeamCity that the deployment is still executing, no indication of the current status, and no reporting of the final result of the deployment. This makes it difficult to trigger other builds or use the deployment build as a snapshot dependency because it’s not clear when the deployment is actually complete.

## TeamCity Detached Builds to the Rescue!
Starting with the 2020.2 build of TeamCity, there is a feature called detached builds. This was designed for calling external asynchronous services from a TeamCity agent. It makes it possible to simulate the behavior of a synchronous operation on a TeamCity agent even when the call to the external service is asynchronous. This is accomplished by using a callback approach. When the build is detached the TeamCity console shows the build as continuing to execute.

A build step can detach the agent by emitting the service message ##teamcity[buildDetachedFromAgent].  This can be done inside PowerShell or a command line build step by echoing the service message to the console:

```cmd
echo ##teamcity[buildDetachedFromAgent]
```

## Detached Builds Release the Agent
As soon as the build receives the buildDetachedFromAgent service message it releases the build agent back to the agent pool so that it can service a new request. However, from the UI and the TeamCity Server perspective the build continues to be in progress. So the UI shows the build as still running even though there is no longer an agent actively executing it.

To show status messages, log errors, or finish the build requires an API call back to TeamCity. The external service that was called before the build was detached needs to call back to TeamCity through the REST API.  The calls look something like below and full documentation can be found in [TeamCity BuildApi REST documentation](https://www.jetbrains.com/help/teamcity/rest/buildapi.html).

```
https://{team_city_host}/app/rest/builds/id:{build_id}/finish
```

This call tells TeamCity to mark the build as completed. The {build_id} parameter here is the global team city build id (teamcity.build.id) that uniquely identifies an instance of a running build.

## Detached Build Licensing (TeamCity)
Even though detached builds do not consume an agent, the TeamCity server has a limit to the number of detached build agents that can be running at one time. The limit is the same as the number of agent licenses on the server. The count of detached builds is global, so regardless of how many agents are in a pool available to run a particular build, the detached agent count can consume all detached agent licenses on a server. Even if the build is only available to run on the 5 agents in the pool, it could consume all detached build licenses available on the server.

> **Important safety tip** - When the number of detached agents licenses are consumed, TeamCity will no longer allow builds to detach and will continue to execute on actual build agents(consuming the agent).

# Conclusion
Asynchronous external services like those found in AWS can be awkward to integrate with TeamCity. Using detached builds allows the invocation of these services with a more seamless synchronous integration user experience in the TeamCity UI. This approach allows these builds to report status as they execute, be used as triggering builds, be used as snapshot dependencies, and provide a status indicating the result of the external service invocation.