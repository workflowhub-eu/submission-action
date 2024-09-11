FROM ruby:3.2.5-slim-bullseye

COPY Gemfile* ./

RUN bundle install

COPY . .

ENTRYPOINT ["ruby", "/submit.rb"]
