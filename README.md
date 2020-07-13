# Blitz Interview

## Notes
I tried to use as few third party libraries as possible for this project, mostly for the learning experience.

Due to time constraints, there were a few things that I wanted to do but couldn't:

* better error handling/logging
* better way to deal with rate limiting
* add tests

## Run

Before running, set the following environment variables:

* REGION (defaults to NA1)
* RIOT_KEY
* SUMMONER_NAME

```bash
REGION=NA1 SUMMONER_NAME=donthurtmepls RIOT_KEY=XXX mix run --no-halt lib/blitz.ex
```
