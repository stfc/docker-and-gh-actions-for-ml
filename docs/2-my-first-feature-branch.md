---
title: 2. My first feature branch
---

# 2. :sparkles: My first feature branch

Now that we've got our repo forked and cloned with our git-flow skeleton in place, we can see the flow in action by completing our first feature!

## Calling our API endpoints

Let's try and figure out what `hbaas` API is doing after all, then!

Make sure the API is running with `./hbaas-server` if it isn't already and let's check out what the root endpoint gives us:

```bash
curl -s localhost:8000 | jq
```
```json
{
	"message": "Welcome! Try sending a request to '/name/{some-name}' to get started!"
}
```

It looks like the endpoint `/name/{value}` is a valid endpoint, so let's try giving that a go:

```bash
curl -s localhost:8000/name/Benedict%20Cumberbatch | jq
```
```json
{
	"message": "Happy birthday Benedict Cumberbatch!"
}
```

Now we can see what the our API is doing - it's providing Happy Birthday as a Service (HBaaS)!

## Adding our feature!

So we've got our endpoint to wish anyone we want happy birthday, but we want to be able to do more than that!

We're going to add a new endpoint to this API that will enable us to wish people a happy birthday by specifying a *date* - the API will then look up all the people with the specified birthday and wish them a happy birthday!

Luckily for us, most of the hard work for this feature is already there - if you look at `handlers/birthday.go`, you'll see the code that implements the endpoints that we've got at the moment.

!!! question "Exercise 2.1"
	Somewhere in the code is a mapping from a particular day to a list of people's names. Where in this codebase is that mapping?

??? hint "Hint 2.1 - click to reveal"
	In Go:
	
	* Types are specified after the variable name mappings, e.g. `my_variable string`.
	* Mappings use the type `map[KeyType]ValueType`, where `KeyType` is the type of the mapping key and `ValueType` is the type of the mapping value.
	* Lists or arrays in Go looks like `[]type`.
	
	This means we're looking for something that looks like `map[BirthDay][]string`. Both grep and ripgrep are pre-installed on the VM, so you can use these to find the code.

??? answers "Answers 2.1 - click to reveal"
	The actual endpoints are in `handlers/birthday.go`. If you look at line 13, you can see that the handler has a `Context` variable:

	!!! example "`handlers/birthday.go`"
		```go linenums="9" hl_lines="6-8"
			"github.com/labstack/echo/v4"

			"hartree.stfc.ac.uk/hbaas-server/context"
		)

		type BirthdayHandler struct {
			Context context.Context
		}

		func (h BirthdayHandler) registerEndpoints(g *echo.Group) {
			g.GET("", h.sayHello)
			g.GET("name/:name", h.sayHappyBirthdayToName)
		}
		```

	We can see from the import on line 11 that this `context.Context` type comes from the `context` package. If we check that out, we can see our mapping right there ready to use:

	!!! example "`context/context.go`"
		```go linenums="1" hl_lines="18"
		package context

		import "time"

		type BirthDay struct {
			Day   int
			Month time.Month
		}

		func NewBirthDay(date time.Time) BirthDay {
			return BirthDay{
				Day:   date.Day(),
				Month: date.Month(),
			}
		}

		type Context struct {
			PeopleByBirthday map[BirthDay][]string
		}
		```

	You could also have found the mapping using ripgrep by running:

	```bash
	rg -F 'map[BirthDay][]string'
	```

!!! info
    If you want to see where this is populated from, take a look at the `data/people.csv` and `data/data.go` files. This CSV file is bundled into the executable and loaded in when the server starts up using the `go embed` feature introduced in Golang v1.16.

	!!! example "`data/data.go`"
		```go linenums="1" hl_lines="5-6"
		package data

		import _ "embed"

		//go:embed people.csv
		var PeopleCSV string
		```

    Obviously, in a real world application we would want our people and birthdays to exist in a database instead of being statically bundled with the API executable, but this goes to show how easy it is in Go to bundle stuff into the final executable without needing to rely on any files at run-time!

Okay, now that we've found our mapping, let's add another endpoint for our date-based happy birthday wishes. Add to the file `handlers/birthday.go` the highlighted lines:

!!! example "`handlers/birthday.go`"
    ```go linenums="1" hl_lines="6-7 21 41-67"
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
		names, exists := h.Context.PeopleByBirthday[birthDay]
		if exists {
			if len(names) > 1 {
				names[len(names)-2] = fmt.Sprintf(
					"%s and %s",
					names[len(names)-2],
					names[len(names)-1],
				)
				names = names[0 : len(names)-1]
			}
			message = fmt.Sprintf(
				"Happy birthday to %s!",
				strings.Join(names, ", "),
			)
		}

		return c.JSON(http.StatusOK, NewAPIMessage(message))
	}
    ```

!!! tip
	The VM comes with Vim, Emacs and nano installed - you can use your editor of preference to modify the file, or install a new one! VS Code also has good support for [remote development using SSH](https://code.visualstudio.com/docs/remote/ssh).

The specifics of this code isn't important for this particular workshop, other than that we're adding an endpoint at `/:date` (where `:date` represents a variable passed through in the endpoint path) and that this endpoint uses our `h.Context.PeopleByBirthday` mapping to look up people who have the birthday specified by the path parameter.

Now that we've got that endpoint added, we can recompile our server and try it out!

```bash
task
./hbaas-server
```

In another terminal tab:

```bash
curl -s localhost:8000/date/11-November
```
```json
{
  "message": "Happy birthday to Leonardo DiCaprio, Demi Moore and Stanley Tucci!"
}
```

!!! tip
    If you're getting "Bad Request" messages back, make sure you're putting the birth dates in the format `{day as number}-{month as full name}`, e.g. for the 2nd May you would do `2-May` and for the 27th February you would do `27-February`.

Try it out with a few more dates - there's almost 300 people listed in there!

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

If you now go to your repository in GitLab, you should create a merge request from this new feature branch to the `dev` branch.

!!! tip
	Make sure that your merge request is pointed at the `dev` branch of your forked repository, not the upstream repository that we originally forked from.

At this point, if you're working in a wider team, you'll want to assign a designated teammate to review the code and approve it. Once it's been approved, you can merge in the changes.

!!! note
    Even if you're working on your own (i.e. without peer review), it's still a good idea to get into the habit of creating merge requests for features and bug fixes - if nothing else, it gives you an opportunity to add additional comments into the merge request to document your development thought process, which is really valuable going forwards.

!!! success
    Congratulations, you've completed your first feature branch! :tada:

	Next we're going to be containerising our API so that we can deploy it to AWS.
