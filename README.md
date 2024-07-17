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
