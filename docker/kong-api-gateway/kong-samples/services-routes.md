# add service

POST /services

{
    "name": "httpbin",
    "retries": 10,
    "protocol": "https" ,
    "host": "httpbin.org",
    "path": "/anything"

}

# add route to a service

POST /routes

{

    "name": "httpbin",
    "service": { "name":"httpbin" },
    "protocols": [ "http" ] ,
    "methods": [ "GET" ],
    "paths": [ "/httpbin" ]

}

# update a service

PATCH /services/httpbin

{
    "name": "httpbin",
    "retries": 5,
    "protocol": "https" ,
    "port": 443,
    "host": "httpbin.org",
    "path": "/anything"

}