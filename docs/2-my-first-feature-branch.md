---
title: 2. My first feature branch
---

# 2. :sparkles: My first feature branch

Now that we've got our repo forked and cloned with our git flow skeleton in place, we can see the flow in action by completing our first feature!

## Compiling our server

Before we add our first, let's first get our server compiled and running so that we can make sure that we've got our system set up with all the dependencies.

The entrypoint to our various build commands is the `Makefile` - let's see what options we've got:

```bash
make help
>
> Choose a command run in hbaas-server:
> 
>   build                   Build the server executable.
>   build-linux             Build the server executable in the Linux ELF format.
>   code-gen                Generate code before compilation, such as bundled data.
>   download-dependencies   Download all library and binary dependencies.
>   clean                   Clean up all build files.
```

This tells that that in order to build our server, we need to run:

```bash
make build
```

So let's give it a go!

You should see something like this:

![make build output](/images/my-first-feature-branch/make-build.png)

If you've got this far, you've successfully built your Go web service!

One of the best things about Go is that everything happens at built time - the output of this build is a single file, which contains everything we need for our web server:

![built server executable](/images/my-first-feature-branch/built-exe.png)

As our application gets more complication and includes more and more functionality, everything will still always be bundled up in this single executable. This might not seen like a big deal now, but when we get onto the containerisation later, you'll see how much easier this makes our lives!

## Running the server

You might be wondering at this point what exactly this `hbaas-server` is - let's find out!

We can run our server simply by running our built executable file:

```bash
./hbaas-server
```

You should see something like this:

![server output](/images/my-first-feature-branch/server-output.png)

Let's try querying our API to see what's going on:

```bash
curl localhost:8000
> {"message":"Welcome! Try sending a request to '/{some-name}' to get started!"}
```

!!! info
    If you're on Windows using PowerShell without curl, this should be:

    ```powershell
    Invoke-RestMethod -Uri localhost:8000 -Method Get
    ```

    In the rest of this tutorial, I'm find to just refer to the curl commands for brevity - just mentally replace this with the `Invoke-RestMethod` equivalent if you're using PowerShell :slightly_smiling_face:

If you see this message coming back welcome you, that means we're in business! Let's try following the suggestion:

```bash
curl localhost:8000/name/Benedict%20Cumberbatch
> {"message":"Happy birthday Benedict Cumberbatch!"}
```

Now we can see what the our API is doing - it's providing Happy Birthday as a Service (HBaaS)!

## Adding our feature!

So we've got our endpoint to wish anyone we want happy birthday, but we want to be able to do more than that!

We're going to add a new endpoint to this API that will enable us to wish people a happy birthday by specifying the *date* - the API will then look up all the people with the specified birthday and wish them a happy birthday!

Luckily for us, most of the hard work for this feature is already there - if you look at `handlers/birthday.go`, you'll see the code that implements the endpoints that we've got at the moment.

Notice that the `BirthdayHandler` type has a `Context`, and that context has a `PeopleByBirthday` map:

!!! example "`handlers/birthday.go`"
    ```go linenums="13"
    type BirthdayHandler struct {
    	Context context.Context
    }
    ```

!!! example "`context/context.go`"
    ```go linenums="17"
    type Context struct {
    	PeopleByBirthday map[BirthDay][]string
    }
    ```

What this means is that we've already got an object that maps the date of birth to the people with that birthday!

!!! info
    If you want to see where this is populated from, take a look at the `data/people.csv` file. This CSV file is bundled into the executable and loaded in when the server starts up.

    Obviously, in a real world application we would want our people and birthdays to exist in a database instead of being statically bundled with the API executable, but this goes to show how easy it is in Go to bundle stuff into the final executable without needing to rely on any files at run-time!

Okay, so let's add another endpoint for our date-based happy birthday wishes:

!!! example "`handlers/birthday.go`"
    ```go linenums="1" hl_lines="6-7 20 40-60"
    package handlers

    import (
    	"fmt"
    	"net/http"
    	"strings"
    	"time"

    	"github.com/labstack/echo/v4"
    	"hartree.stfc.ac.uk/hbaas-server/context"
    )

    type BirthdayHandler struct {
    	Context context.Context
    }

    func (h BirthdayHandler) registerEndpoints(g *echo.Group) {
    	g.GET("", h.sayHello)
    	g.GET("name/:name", h.sayHappyBirthdayToName)
    	g.GET("date/:date", h.sayHappyBirthdayByDate)
    }

    func (h BirthdayHandler) sayHello(c echo.Context) error {
    	message := fmt.Sprintf("Welcome! Try sending a request to '/name/{some-name}' to get started!")
    	return c.JSON(
    		http.StatusOK,
    		NewAPIMessage(message),
    	)
    }

    func (h BirthdayHandler) sayHappyBirthdayToName(c echo.Context) error {
    	name := c.Param("name")
    	message := fmt.Sprintf("Happy birthday %s!", name)
    	return c.JSON(
    		http.StatusOK,
    		NewAPIMessage(message),
    	)
    }

    func (h BirthdayHandler) sayHappyBirthdayByDate(c echo.Context) error {
    	date := c.Param("date")

    	dateTime, err := time.Parse("2-January", date)
    	if err != nil {
    		return echo.ErrBadRequest
    	}

    	message := "It doesn't look like I know of anyone with that birthday!"

    	birthDay := context.NewBirthDay(dateTime)
    	peopleWithBirthday, exists := h.Context.PeopleByBirthday[birthDay]
    	if exists {
    		message = fmt.Sprintf(
    			"Happy birthday to %s!",
    			strings.Join(peopleWithBirthday, ", "),
    		)
    	}

    	return c.JSON(http.StatusOK, NewAPIMessage(message))
    }
    ```

The specifics of this code isn't enormously important, other than that this is a function on the `BirthdayHandler` type that takes the data loaded into the application context in `h.Context.PeopleByBirthday` and uses that to look up people who have the birthday specified by the request parameter.

Now that we've got that endpoint added, we can recompile our server and try it out!

```bash
make build
./hbaas-server

# In another terminal
curl localhost:8000/date/2-November
> {"message":"Happy birthday to David Schwimmer!"}
```

!!! tip
    If you're getting "Bad Request" messages back, make sure you're putting the birth dates in the format `{day as number}-{month as full name}`, e.g. for the 2nd May you would do `2-May` and for the 27th February you would do `27-February`.

Now that this feature is implemented and working, we're ready to merge it back into the `dev` branch:

```bash
# Make sure we're branching our feature branch out from dev
git checkout dev

# Create our new feature branch
git checkout -b feature/add-happy-birthday-by-date

git add handlers/birthday.go
git commit -m "Add endpoint for wishing people happy birthday by date."

git push --set-upstream origin feature/add-happy-birthday-by-date
```

If you now go to your repository in GitLab, you should create a merge request from this new feature branch to the dev branch.

!!! note
    Even if you're working on your own (i.e. without peer review), it's still a good idea to get into the habit of creating merge requests for features and bug fixes - if nothing else, it gives you an opportunity to add additional comments into the merge request to document your development thought process, which is really valuable going forwards.

!!! success
    Congratulations, you've completed your first feature branch!
