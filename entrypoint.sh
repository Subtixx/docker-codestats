#!/bin/bash

cd /code-stats
mix ecto.setup
mix run priv/repo/seeds.exs

cd /app/code_stats
./bin/code_stats start