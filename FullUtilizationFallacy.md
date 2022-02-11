# The 100% Utilization Fallacy
Recently I've been thinking a lot about developer and team productivity.  I've realized that one of the factors that has a significant impact on a teams' efficiency and productivity is the amount of work in progress (WIP) they have at any given time.  Too much WIP is a really bad thing for team workflow. In fact, in the book Making Work Visible: Exposing Time Theft to Optimize Work & Flow by by Dominica Degrandis, she calls too much WIP "Time Thief #1".  This is a great way to describe too much WIP!  A Time Thief!

> Having too much WIP can have a significant negative impact on team productivity.

## The problems with too much WIP
So why is it bad to have too much WIP?  It would seem the more tasks that a developer actively works on, the more they will eventually complete.  We never want a developer to run out of tasks to work on, right?  Having expensive resources sitting idle doesn't seem like a good utilization strategy.

Following this line of reasoning, the common way to ensure this doesn't happen is to maintain large amounts of work in each developer's backlog.  This way they never run out of things to work on.  This reasoning is compelling, however in reality it is a fallacy and actually decreases total team productivity and throughput.  

So why does having too much WIP decrease team productivity?

### Requires Context Switching
Unlike computers, the human brain is really bad at context switching.  In fact [studies](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2864034/) have shown that the average person can only hold 3-5 separate items in short-term memory at one time.  Every time a new item needs to be thought about, the mind needs to access long-term memory.  Because of this extra overhead, being able to focus on a small number of things at once allows us to make faster and more meaningful progress than having to continuously context switch between multiple un-related tasks.  

Even a computer (which is relatively fast at context switching) is slowed significantly by having too many programs constantly moving data in and out of memory.  If you've ever used a computer whose processor is near 100% utilization you know that it is not operating at its peak efficiency. 

When developers have too many tasks in progress at once they spend a significant amount of time context switching between the tasks.  It doesn't take very many tasks for this to quickly become a productivity bottleneck.   

Most developers have other responsibilities besides just the tasks they are assigned, such as meetings, operational support, continuous learning, etc.  With all of these context switches already in progress, adding multiple tasks to their queue and backlog quickly makes context switching a major impediment.  

### Provides No Time for Emergent Work
Software development is knowledge work and, no matter how hard we try to fully define tasks, there always tends to be unexpected work.  It's difficult to predict all of the detailed work required in order to finish a task or story.  While working on tasks we  frequently discover emergent work.  This means completing more work than was initially planned.

When a developer has a full backlog of tasks, it creates an environment where it feels like there isn't time to complete emergent work.  This can lead to hastily finished tasks, low quality work, increased technical debt, and increased operational burden for the team and organization.  Although the immediate task may be completed, there is additional work necessary in the future to correct or recover from the technical debt.  

Instead of spending the extra 20% effort it would have taken to get the task done well the first time, it will be necessary to return to the task in the future and expend a much greater level of effort.

### Provides No Time for Learning or Innovation
One of the biggest challenges for any technical team or organization is keeping pace with the rapidly changing technology landscape.  In order to stay competitive it is imperative that IT organizations continue to learn, innovate, and leverage relevant technologies.   To do this effectively requires an organizational mindset of continuous learning and growth.  

Innovation and learning requires dedicated time from technology professionals.   Without this, teams tend to stagnate instead of grow.  When developers are already fully tasked, it doesn't leave any time for innovation and growth.

### Increases Stress
Having too many tasks in your queue can be overwhelming.  People feel stressed when they have more work than they can do.  This is generally true for all contexts and not just software development.  

Being overwhelmed in this way can create a false sense of urgency and pressure.  This increases the stress level and risk of burnout for the developer and also increases the risk of making errors and incurring technical debt.  Feeling overwhelmed makes it much more likely for a developer to feel pressure to take short-cuts and close tasks without properly finishing them.  Usually these types of short-cuts result in long-term technical debt and operational burden.  

Developers are less likely to ask for input from others (because that takes more time and the other developers have large backlogs of tasks too) or even give the problem the thought and concentration it deserves. 

> The old adage that the best way to go faster is to slow down definitely applies to software development.  Taking your time, focusing on tasks, and doing it better the first time is critical to efficient developer and team productivity. 

One of the biggest issues with increased stress or burnout is that it disengages the developer from their work.  Team engagement is directly proportional to productivity.   When a team member feels satisfied and fulfilled by their work they are much more likely to be engaged and have a higher sense of product ownership.  Increased stress through an overwhelming number of tasks and competing priorities puts this engagement at risk.

### Increases Unnecessary Coordination
When project managers assign tasks to developers, many times this occurs without consideration of context.  There may not be a lot of thought about previous work done by a member of the team that may have a bearing on the ability of the developer to complete the task.  Instead of letting the developer pull the tasks for which they have the most context, this model encourages more random assignment of tasks to resources.  

Many times this means increased coordination with other team members to obtain the context to actually complete the task.   Sometimes this context sharing takes a significant or larger amount of time than just having the developer with the context complete the task.  

The usual rationalization for this decrease in productivity is that it increases knowledge sharing and collaboration.  It does increase knowledge sharing and collaboration, but it is inefficient and unnecessary collaboration.  There are more efficient ways to knowledge share not only with that one developer, but with the entire team.  This small incremental increase in knowledge sharing does not justify the steep price in productivity that is being paid by the team and organization.

### Decreases Work Throughput
The net effect of too much WIP is decreased team efficiency and work throughput.  Just as there is a limit to the number of automobiles that can travel on a freeway efficiently, there is also a limit to the number of tasks that can be in an agile sprint for optimal work production from the team.  

If you have too many vehicles on a road, the road quickly becomes congested and slowed by unexpected events like accidents and distracted  drivers.  In much the same way, having too many tasks in the immediate team queue or sprint can increase the work congestion and slow down the entire team.

## So why is 100% utilization so prevalent?
The reason that we see so many teams aiming for 100% utilization is that it feels like the best way to keep the team moving forward and getting more work done.  As we mentioned before, there is fear attached to not keeping these expensive resources allocated 100% of the time.  It is counterintuitive that the best way to improve a team's productivity and throughput is through actually decreasing the amount of WIP.  

## What can we do?
### Under-load sprints
A team will be more productive if their sprints are slightly under-loaded.  It's a good idea to shoot for a resource utilization that is under 100%.  The exact percentage probably varies from team-to-team, but an effective allocation is probably somewhere in the 70-80% range.  

Accurately estimating a certain percentage of work for a sprint can be difficult.  The important thing to remember is that it doesn't have to be perfect.  There are a couple of tricks you can use to help:
- Keep sprints as short as possible. The shorter the period of time, the more adequate the predictions on the amount of work that can be completed.  
- When estimating the amount to complete, decrease the duration available in the sprint.  As an example, if the sprint is one week (five days) then ask the team what they can get done assuming the sprint was only four days.  
- Adjust as necessary.  As part of your sprint retrospective review the accuracy of the tasks assigned during the previous sprint.  Was there too much or too little WIP?  As the team works together longer, the estimates should become more and more accurate. 

Making these adjustments will increase flow and avoid unnecessary context switching.  Thereby providing time for emergent work, innovation, and fast flow. 

### Pull vs Push for Task Assignment
Allow developers to manage their personal work-in-progress and backlog of tasks.  Instead of loading a developer's backlog and in-progress queue with tasks ahead of time, add an appropriate number of well-groomed and unassigned tasks to the team backlog.  In this way, these tasks still belong to the team and are not an immediate psychological weight on any one developer.  

This helps to increase developer autonomy, product ownership, and engagement on the team.   It allows developers to pick up the tasks that they are best suited to complete in an efficient and timely fashion.  

# Conclusion
You can help your team operate more efficiently and get more done by controlling WIP.  This also increases developer engagement and the quality of the product the team is creating.  It takes some mindfulness of the sprint task load and discipline from the team, but the results are well worth the effort.