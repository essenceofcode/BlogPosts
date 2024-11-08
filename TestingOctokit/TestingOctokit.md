# Testing Octokit with High-fidelity Fakes

Recently I've been working on an application that needs to retrieve and analyze data about GitHub repositories. This application is written in C# using the .NET 8.0 framework, so a natural choice for this is to use the Octokit GitHub API Client Library for .NET (https://github.com/octokit/octokit.net). This client library works great and makes it very easy for the application to interact with the GitHub API.

The application uses custom logic to analyze, consolidate, and make inferences about GitHub repositories. Since there is a bit of custom logic, it's important to be able to write effective unit tests. To accomplish this, it is necessary to mock the responses from the Octokit SDK.  

There are a couple of options for doing this kind of mocking. One way to do this is to use a mocking framework in .NET like [MOQ](https://github.com/moq) or [FakeItEasy](https://fakeiteasy.github.io/). I've used these types of mocking frameworks in the past, but found that the resulting tests tend to be brittle and difficult to maintain over time. They also tend to lead to a lot of repeated and difficult to read mocking code. 

Another alternative that I've started applying lately is outlined in Chapter 18 of [Test Doubles of the book Software Engineering at Google: Lessons Learned from Programming Over Time 1st Edition](https://a.co/d/3h7T1nd) by Titus Winters, Tom Manshreck, and Hyrum Wright. In this chapter they outline the case for using the real class implementations of dependencies in tests when possible and high-fidelity fully-functioning fakes when it isn't. One of the cases where using the actual implementation isn't practical is when those dependencies need to interact with components outside of the codebase's process (API calls, database calls, caching calls, etc). In this particular case the Octokit client is making HTTPS REST API calls to retrieve and update data. Using real calls to these dependencies is impractical because it would lead to non-determinism, performance issues, and unnecessary maintenance in the tests. So I started looking for a way to build a high-fidelity fake of the GitHub clients. 

> **TLDR;** This post explains how to use the GitHub Octokit client interfaces and a json fixture text file to create high-fidelity fake for testing in C#. This allows the testing of custom logic that depends on external calls to the GitHub API. For brevity and understandability, the example here shows how to do this for only one type of data and one API call. Although this could be easily extended to cover all functionality in the Octokit client.

## Approach Overview
This approach creates fake versions of the Octokit GitHub clients using the interfaces that are part of the SDK. The fake client loads pre-configured fake data from a JSON fixture file and provides it back to the caller. It also emulates the error responses from the client when data is not found.

![Fake GitHub Client Class Diagram](GitHubClient.svg)

This diagram illustrates that the application logic relies on Octokit's IGitHubClient, IRepositoriesClient, and the IRepositoryBranchesClient. At runtime either the fake or real implementation for these dependencies are used. For the real logic, the actual GitHub SDK client is used, but for the tests the fake version is used.

## Example: Branch Data
To simplify this example and to illustrate how to create and leverage a fake for Octokit, this post explains the approach for faking a single SDK call and response for branch data. It will walk through creating fake data, persisting it in a fixture file, creating a fake Octokit client, and injecting it as part of a test. This is just an example of how to create a fake GitHub client for one API call, but the pattern could be extended to the entire SDK.

## High-fidelity Fake Data
The first challenge to creating a fake for the Octokit SDK was generating responses that were as close to the real implementation as possible. I knew how to retrieve sample data from GitHub organizations and repositories, so I decided to try and use API calls to get real examples of API responses.

>Nothing is higher fidelity data than examples from real API calls.

The curl network call below shows how to make a call to the GitHub API to retrieve branch data. Please note that this is an example and not a real URL. The organization and repository have been replaced with non-existent values.

***Get Example Branches JSON***
```bash
curl -L -H "Accept: application/vnd.github+json" -H "Authorization: token $token" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/fake/does-not-exist/branches/main
```

This API call returned data that looked similar to the data below. Note that this data has also been redacted to make sure it does not expose any data from a real repository. It has also been abbreviated (note the ellipses) to minimize the length of this post. 

> ***Note: It is always recommended to use an example repository or to scrub the data in your tests to remove any possible real data from your test data.***


### BranchesFixture.json
```json
[
  {
    "organization": "fake-org",
    "repository": "fake-repo",
    "branch": {
      "name": "main",
      "protected": true,
      "commit": {
        "sha": "123456asdf123456asdf123456asdf",
        "node_id": "COMPLETELYFAKE",
        "commit": {
          "author": {
            "name": "User, Fake",
            "email": "fake.user@notrealemail",
            "date": "2024-09-26T17:16:09Z"
          },
 
        ...

        }
      },
      "protection_url": "https://api.github.com/repos/fake-org/fake-repo/branches/main/protection"
    }
  }
]
```
## Creating Fake GitHub Clients
The next step is to create the fake Octokit SDK clients. 

***GitHubClientFake.cs*** 

The primary purpose of the Octokit interface IGitHubClient is to be a factory for creating the various clients used by the SDK. The fake implementation of this client creates and returns our other fake clients. In this example it returns the RepositoriesClientFake.
```csharp
using Octokit;

namespace Tests.Fakes.GitHub
{
    internal class GitHubClientFake : IGitHubClient
    {
        public IConnection Connection => new ConnectionFake();

        public IGitHubAppsClient GitHubApps => new AppsClientFake();
        
        public IRepositoriesClient Repository => new RepositoriesClientFake();

        public IPullRequestsClient PullRequest => new PullRequestClientFake();

        ... 

        public ApiInfo GetLastApiInfo()
        {
            throw new NotImplementedException();
        }

        public void SetRequestTimeout(TimeSpan timeout)
        {
            throw new NotImplementedException();
        }
    }
}
```

***RepositoriesClientFake.cs***

Likewise, the RepositoriesClientFake creates and returnes the BranchesClientFake implementation.
```csharp
using Octokit;
using Octokit.Internal;

namespace Tests.Fakes.GitHub
{
    internal class RepositoriesClientFake : IRepositoriesClient
    {
        public IRepositoryBranchesClient Branch => new BranchesClientFake();

        public IRepositoryCommitsClient Commit => new RepositoryCommitClientFake();

        public IPullRequestsClient PullRequest => throw new NotImplementedException();

        public IRepositoryActionsClient Actions => throw new NotImplementedException();
```
***BranchesClientFake.cs***

The branches client fake has the actual fake implementation logic in it. 
```csharp
using Octokit;
using Octokit.Internal;

namespace Tests.Fakes.GitHub
{
    public class CustomBranch {
        public Branch? Branch { get; set; }
        public string? Organization { get; set; }
        public string? Repository { get; set; }
    }

    public class BranchesClientFake : IRepositoryBranchesClient
    {
      readonly IList<CustomBranch> _branches;
      
      public BranchesClientFake()
      {
          var serializer = new SimpleJsonSerializer();

          string branchesJson = File.ReadAllText("Fixtures/BranchesFixture.json");

          _branches = serializer.Deserialize<List<CustomBranch>>(branchesJson);
      }

      public Task<Branch> Get(string owner, string name, string branchName)
      {
          var result = _branches.FirstOrDefault(branch => branch.Organization == owner && branch.Repository == name && branch.Branch?.Name == branchName)?.Branch;

          return result == null
              ? throw new NotFoundException("Branch does not exist.", System.Net.HttpStatusCode.NotFound)
              : Task.FromResult(result);
      }

      public Task<EnforceAdmins> AddAdminEnforcement(string owner, string name, string branch)
      {
          throw new NotImplementedException();
      }
      ...
    }
  ]
} 
```
We have defined a new custom data structure classes here to allow the branch data to be read from the fixture for multiple repositories. It also identifies the organization so that it's possible to have fake data for multiple organizations and multiple repositories in those organizations.

The constructor here uses System.Text.Json to read the json fixture with the fake data into the C# data structures. The Get method then uses a lambda function against this data to search the data by organization, repository, and branch name. 

It also simulates the condition when no data is found by throwing a NotFoundException.

## Using the Fake Clients in a Test
Now to use this fake client in a test all we have to do is wire it up and inject it into our custom logic.
```csharp

using Custom.Functions.GitHubServices;
using Tests.Fakes.GitHub;
using Xunit;

namespace Tests.GitHubServices;

public class BranchServiceShould
{
  private readonly GitHubClientFake _client;

  public BranchServiceShould()
  {
      _client = new GitHubClientFake();
  }

  [Fact]
  public async Task GetBranchDetails()
  {
      var request = new AnalyzeRepositoryRequest
      {
          GitHubApiUrl = "https://api.github.com/",
          GitHubOrganizationName = "fake-org",
          RepositoryName = "fake-repo",
          GitHubSecret = "FakeSecret"
      };

      var result = await BranchService.Get(_client, request, "main");

      Assert.Equal(result.Name, "main");
      Assert.True(result.Protected);
  }
}
```
This is only a single test, but it shows how simple the tests can be if the fake data is setup correctly. You would want to add more tests and additional fake data to fully cover the service, but this shows the mechanics of wiring it up. It would also be very easy to extend these clients to allow updates and deletes for an even higher fidelity service.

## Conclusion
This approach shows how to use fake local data in a test to exercise custom logic that depends on the external API calls from the Octokit SDK. Using this approach makes it simple to add additional tests, keeps the tests clean, and allows the entire framework that is loaded in the tests to be exercised.