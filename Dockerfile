FROM ruby:2.7.2

RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev postgresql-client yarn

## update node
RUN curl -sL https://deb.nodesource.com/setup_16.x -o /tmp/nodesource_setup.sh
RUN chmod +x /tmp/nodesource_setup.sh
RUN ./tmp/nodesource_setup.sh
RUN apt install -y nodejs
## update node
## Copy Files
WORKDIR /sample_rails_application
COPY Gemfile .
COPY Gemfile.lock .
COPY package.json .
COPY yarn.lock .
## Copy Files
## Install Pacotes
RUN gem install bundler -v '2.2.15'
RUN bundle install
RUN yarn install --check-files
## Install Pacotes

ENV NEW_RELIC_APP_NAME='ruby' \
    NEW_RELIC_LICENSE_KEY="" \
    NEW_RELIC_SPAN_EVENTS_MAX_SAMPLES_STORED=1000 \
    NEW_RELIC_DISTRIBUTED_TRACING_ENABLED=true


COPY . .
RUN rails db:migrate
RUN rake db:seed
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]