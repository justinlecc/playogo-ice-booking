FROM ruby:2.3.8

# Point apt to the Stretch archive (no stretch-updates), and relax signature/validity checks
RUN set -eux; \
  echo 'deb http://archive.debian.org/debian stretch main' > /etc/apt/sources.list; \
  echo 'deb http://archive.debian.org/debian-security stretch/updates main' >> /etc/apt/sources.list; \
  printf 'Acquire::Check-Valid-Until "false";\nAcquire::AllowInsecureRepositories "true";\n' > /etc/apt/apt.conf.d/99archive; \
  apt-get -o Acquire::Check-Valid-Until=false -o Acquire::AllowInsecureRepositories=true update; \
  apt-get install -y --no-install-recommends --allow-unauthenticated \
    build-essential nodejs postgresql-client ca-certificates; \
  rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY Gemfile Gemfile.lock ./

# Old Bundler for Rails 4-era lockfiles
RUN gem install bundler -v 1.17.3 && bundle _1.17.3_ install

COPY . .
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]

