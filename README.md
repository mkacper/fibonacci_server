# FibonacciServer

This application provides an HTTP API for calculating Fibonacci sequence. 

### Supported features:
* listing Fibonacci sequence
* fetching Fibonacci value for a particular number (nth element of the
    sequence)
* adding and removing particular numbers (nth element of the sequence)
    to/from a blacklist

## Requirements

* Elixir 1.17.1
* Erlang 26.1.2

## Running application locally

Follow the steps below to have the application up and running
at [`http://localhost:4000`](http://localhost:4000).

#### Option A - use elixir releases (for `DEV` env)

Run the below commands, in the project root directory, to run the app:

```bash
make build-dev-release
_build/dev/rel/fibonacci_server/bin/server

# run in another shell to test if the server works
curl http://localhost:4000/api/sequence?number=10
```

> NOTE: It builds release for DEV environment to streamline the process.
It's not a production release.

#### Option B - use docker

Run the below commands in the project root directory:

```bash
make docker-build
SECRET_KEY_BASE=$(openssl rand -base64 48) PORT=4000 PHX_HOST="localhost" make docker-run

# test if the server works
curl http://localhost:4000/api/sequence?number=10
```

> NOTE: In case `openssl` is not available some random string for
`SECRET_KEY_BASE` env variable can be used.

> NOTE 2: Tested on MacOS with Docker version 20.10.17, build 100c701

## HTTP API endpoints

1. List Fibonacci sequence
- path: `/api/sequence`
- method: `GET`
- supported query params:
    - `number` (required) - nth element of the sequence
    - `page_size` (optional; default 100) - number of sequence elements returned in a single
        response
    - `cursor` (optional for the first page, required for the consecutive
        pages) - pointer to the next page of the results; returned as part
        of the response from this endpoint when using paging; using
        arbitrary/random values for this parameter can cause incorrect
        results
- response codes:
    - `200` - sequence listed successfully
    - `400` - incorrect parameters
- example:
    ```bash
    curl http://localhost:4000/api/sequence?number=10&page_size=5
    ```
    ```json
    {
       "data":[
          {
             "index":0,
             "value":0
          },
          {
             "index":1,
             "value":1
          },
          {
             "index":2,
             "value":1
          },
          {
             "index":3,
             "value":2
          },
          {
             "index":4,
             "value":3
          }
       ],
       "next_cursor":5
    }
    ```

2. Get Fibonacci sequence nth value
- path: `/api/value/<number>`
- method: `GET`
- supported path params:
    - `number` (required) - nth element of the sequence
- response codes:
    - `200` - value returned successfully
    - `400` - incorrect parameters
    - `404` - number not found (blacklisted)
- example:
    ```bash
    curl http://localhost:4000/api/value/10
    ```
    ```json
    {
        "data": 55
    }
    ```

3. Add Fibonacci sequence nth element to the blacklist
- path: `/api/blacklist/numbers`
- method: `POST`
- supported body params:
    - `number` (required) - nth element of the sequence
- response codes:
    - `201` - number added to the blacklist successfully
    - `400` - incorrect parameters
- example:
    ```bash
    curl -X POST -H "Content-Type: application/json" http://localhost:4000/api/blacklist/numbers -d '{"number":37}'
    ```
    ```json
    {
        "result": "ok"
    }
    ```

4. Remove Fibonacci sequence nth element from the blacklist
- path: `/api/blacklist/numbers/<number>`
- method: `DELETE`
- supported path params:
    - `number` (required) - nth element of the sequence
- response codes:
    - `200` - number removed from the blacklist successfully
    - `400` - incorrect parameters
- example:
    ```bash
    curl -X DELETE http://localhost:4000/api/blacklist/numbers/37
    ```
    ```json
    {
        "result": "ok"
    }
    ```

## Implementation details

In this section, I will explain some of the decisions and trade-offs made while
building this application.

### Listing sequence paging

I decided to use cursor-like paging because some of the numbers might be
blacklisted. An offset-based approach can be tricky here, especially if the
blacklist is modified while paging through the results. If there are multiple
pages, the blacklisted numbers are backfilled so the intermediate pages do not
contain "holes" but have the correct number of results.

One can also consider capping the maximum page size or using HTTP streaming
to prevent sending too much data in a single response.

### Blacklist

For storing the blacklisted numbers, I used a process-based approach (Agent).
This could become a bottleneck if there are many concurrent requests.
Some alternative solutions, such as ETS, could be considered.

### Calculating Fibonacci sequence

I've used the most basic approach, leveraging recursion and tail-recursive
functions. This method does not work well for large "N" elements. There are
limitations regarding memory usage (numbers grow quickly, and system limits
can be reached fairly easily) and CPU usage. More sophisticated algorithms
could be used here to optimize memory and CPU usage. I have not researched
these algorithms in detail, but I know they exist ([examples](https://www.nayuki.io/page/fast-fibonacci-algorithms))).

We could also cache results so subsequent calls can use pre-calculated values,
avoiding repeated calculations.

### Concurrency approach to handling requests


Currently, all calculations happen synchronously in the process that handles
an HTTP request. There are some trade-offs here:

 - Long-running calculations may hang the HTTP request and eventually time out.
    This could be mitigated with an asynchronous approach.
 - There is a lack of control over the number of requests being handled
    simultaneously. Running too many of them may consume excessive resources.
    To address this, we could have dedicated worker(s) that queue the tasks
    and process them in a controlled manner.

### Missing pieces/TODOs

- add functions specs and docs
- add more tests
- improve test helpers
- improve API parameters validations
- improve handling `cursor` for sequence API paging (should be opaque to the caller)
- improve blacklist API responses
- remove Phoenix leftovers
