# Maxeem

**Raxx + Redix assignment**

[assignment.pdf]("./assignment.pdf")

# start Redis
~~~text
$ redis-server // tested on Redis 5.0.7
~~~
# get app
~~~text
$ git clone https://github.com/maxeema/maxeem && cd maxeem
~~~
# test app
~~~text
$ mix test
~~~
# launch app
~~~text
$ mix run --no-halt
~~~
# try app
~~~text
$ curl "localhost:8080/visited_links" -d "{ \"links\": [ null, \"https://fb.com/cool\", \"\", \" \", \"https://bing.com?search=cats\", \"fb.com\", \"https://stackoverflow.com/questions/0\" ] }"; echo
~~~
~~~text
$ curl "localhost:8080/visited_domains?from=1577618347&to=1677618347"; echo
~~~
