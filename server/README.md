# Anagram Server

to setup:

```
bundle install
```

to run:

```
puma
```

## examples

upload big dictionary

```
curl -i -X POST -d @dictionary.json localhost:9292/words.json
```

get stats

```
curl -i localhost:9292/stats.json
```

## notes

* assumes MRI ruby.  If rbx or jruby, change Gemfile to use 'concurrent-ruby'
* uses a lot of memory. I'm looking to see what is being used
* assumes a single process, multiple threads.  Multiple process just wont work.
