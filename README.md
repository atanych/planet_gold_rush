## How to run
1. `docker-compose up --build`
2. curl -X POST http://127.0.0.1:3000/events\?event\=evt1
3. `docker-compose exec web rspec` # tests

## Notes:
* If we dont receive requests on `/events` during 1 minute, next request immediately triggers batch to external service
* In consumer#handle_iteration we might use `llen` before, then `lrange`. But have a look at benchmark `docker-compose exec web rake benchmark:llen_vs_lrange`.
```
               user     system      total        real
lrange:    0.000000   0.000000   0.000000 (  0.000278)
llen:      0.000000   0.000000   0.000000 (  0.000262)
```
* Request limitations!!! 8 CPU, 16 memory: 1000 requests per 1.5sec (100 batch requests/1.5sec). Looks like we might handle 1000 requests/sec, if we vertically scale CPU and memory.
`rake benchmark:handle_iteration`
```
*** consumer#handle_iteration ***
Handled 1000 requests
1.527002s
```
* Before production we have to replace inline queue adapter with sidekiq/resque
* This solution does not support to scale the consumer as is. But we might use other redis keys.
