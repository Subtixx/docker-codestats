FROM hexpm/elixir:1.14.3-erlang-25.2.2-ubuntu-focal-20221130

ENV MIX_ENV "prod"
ENV MINIFY true

RUN apt-get update && \
    apt-get -y install git ca-certificates curl gnupg build-essential curl && \
    mkdir -p /etc/apt/keyrings && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_16.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get -y install nodejs && \
    git clone https://gitlab.com/code-stats/code-stats.git /code-stats

WORKDIR /code-stats

RUN mix local.hex --force  && \
    mix local.rebar --force && \
    mix deps.get && \
    cd assets && npm install && npm ci && cd .. && \
    mix compile --force && \
    mix frontend.build && \
    mix phx.digest && \
    mix release --overwrite

ENV EMAIL_FROM_ADDRESS "admin@local.host"
ENV PORT 5000
ENV HOST localhost
ENV HOST_PORT 5000
ENV PORT 5000
ENV SECRET_KEY_BASE "a02972d2a240dfb0a1634a95fe268af65635403abcad5758c176e0dc868cb47ac8ecbced27e47bd077244df5e0298e9b76d7bae0faaf9d43e6c32280cbb53f47"
ENV SITE_NAME "Code::Stats"
ENV BETA_MODE false
ENV SOCIAL_LINKS '[["Twitter", "https://twitter.com/code_stats"], ["Discord", "https://discord.gg/gyzRfjc"], ["Gitter", "https://gitter.im/code-stats/Lobby"], ["IRC", "irc://irc.freenode.net/codestats"], ["Matrix", "https://matrix.to/#/#code_stats:matrix.org"]]'
ENV ANALYTICS_CODE ""
ENV DB_HOST "localhost"
ENV DB_USER "codestats"
ENV DB_NAME "codestats"
ENV DB_PASS "codestats"
ENV DB_POOL_SIZE 10
ENV ADS_ENABLED false
ENV EA_PUBLISHER "foobar"
ENV GUMROAD_ACCESS_TOKEN "abcd"

WORKDIR /app

COPY ./entrypoint.sh /app/entrypoint.sh
COPY language_colours.json /app/code_stats/language_colours.json

RUN cp -r /code-stats/_build/prod/rel/code_stats /app && \
    chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]