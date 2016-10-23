FROM trenpixster/elixir:1.2.0
MAINTAINER Fabien Bessez <fbessez@bleacherreport.com>

ADD . /app

RUN mix local.rebar
RUN mix local.hex --force

WORKDIR /app

RUN rm -rf _build
RUN rm -rf deps

ENV MIX_ENV dev
ENV PORT 4010

RUN mix do deps.get, compile
RUN mix compile.protocols

EXPOSE 4010

CMD ["mix", "phoenix.server"]