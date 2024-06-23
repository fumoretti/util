# Adding Oauth2 to a KONG route (TL;DR)

## add plugin to route and take note of provision key

```bash
curl -X POST \
-H http://localhost:8001/routes/myroute/plugins \
--data "name=oauth2" \
--data "config.scopes=email" \
--data "config.mandatory_scope=true" \
--data "config.enable_password_grant=true"
```

## add plugin to consumer and take note of outputed data

```bash
curl -X POST -H \
http://localhost:8001/consumers/myconsumer/oauth2 \
--data "name=myconsumer" \
--data "redirect_uris[]=http://kong.local.lan:8000/myroute/callback"
```

## generate a token every time you need access to the protected route

```bash
curl -X POST http://localhost:8000/myroute/oauth2/token \
--data "grant_type=password" \
--data "client_id=GENERATED_IN_LAST_STEP" \
--data "client_secret=GENERATED_IN_LAST_STEP" \
--data "provision_key=GENERATED_IN_FIRST_STEP" \
--data "authenticated_userid=myconsumer" \
--data "scope=email"
```

# Adding Oauth2 to a route (LONG and Explained)

Explained steps to add oauth2 token generation to a KONG route. This is a more "real life version" and assumes that your KONG api gateway have:

1. an **https://kong.local.lan:8443/myroute** route working with a service
2. a consumer named **myconsumer**
3. a KONG route working with **basic authentication** pointing to internal KONG ADMIN API (**http://kong.local.lan:8000/admin-api** in this example)

If you have an default KONG admin api, change all urls on the steps from _:8000/admin-api_ to _:8001/_ .

## add oauth2 plugin to the existing route

```bash
curl -X POST \
-H "Authorization: Basic YWRtaW46Y2hhbmdlbWU=" http://kong.local.lan:8000/admin-api/routes/myroute/plugins \
--data "name=oauth2" \
--data "config.scopes=email" \
--data "config.mandatory_scope=true" \
--data "config.enable_password_grant=true"
```

From the outputed json, take note of **provision_key** value to use on the next steps. Note that **token_expiration** is KONG default, change as you need. For this example execution, KONG generates the following key:

```
provision_key=k01Q6QtEvT7dHLdWIYcFlL7HTADujEYI
```

## add oauth2 to consumer

```bash
curl -X POST -H \
"Authorization: Basic YWRtaW46Y2hhbmdlbWU=" http://kong.local.lan:8000/admin-api/consumers/myconsumer/oauth2 \
--data "name=myconsumer" \
--data "redirect_uris[]=https://kong.local.lan:8443/myroute/callback"
```

Note that **redirect_uris** needs to be pointed to the route being protected by oauth2 followed by _/callback_ path.

On this step a json is provided with info you need to combine with **provision_key** . In this example, KONG generated the following:

```json
{
  "redirect_uris": [
    "https://kong.local.lan:8443/myroute/callback"
  ],
  "client_id": "XAAFpHgaavFTBdWNazfl5Vm0LfDEbNuw",
  "consumer": {
    "id": "0d4b6222-0b97-4233-9255-3eccd4f69a55"
  },
  "created_at": 1719117701,
  "client_type": "confidential",
  "client_secret": "wFlqxGCIDOafXPWVl7LSuAncaOPePII4",
  "tags": null,
  "name": "myconsumer",
  "id": "3b293a31-c448-45d4-a398-b763a3fc901c",
  "hash_secret": false
}
```

Take note of following fields to be used on the next step:

- client_id
- client_secret
- name

## generate a token every time you need access to the protected route

Based on the out of the last steps in this example, a token can be generated as follow:

```bash
curl -X POST https://kong.local.lan:8443/myroute/oauth2/token \
--data "grant_type=password" \
--data "client_id=XAAFpHgaavFTBdWNazfl5Vm0LfDEbNuw" \
--data "client_secret=wFlqxGCIDOafXPWVl7LSuAncaOPePII4" \
--data "provision_key=k01Q6QtEvT7dHLdWIYcFlL7HTADujEYI" \
--data "authenticated_userid=myconsumer" \
--data "scope=email"
```

Outputed json data:

{
  "access_token": "xVQ5NLxSCAAj1h8KKREeITrgByhZCDgb",
  "refresh_token": "V3obKTwzyPSE2hsCSglYM0GJKbguGjis",
  "token_type": "bearer",
  "expires_in": 7200
}

## using the generated token to access the myroute route

```bash
curl -H "Authorization: Bearer xVQ5NLxSCAAj1h8KKREeITrgByhZCDgb" https://kong.local.lan:8443/myroute
```

This route points to a service using https://httpbin.org/anything, it's dumps information for the requested HTTP access.

The output from route:

```json
{
  "args": {}, 
  "data": "", 
  "files": {}, 
  "form": {}, 
  "headers": {
    "Accept": "*/*", 
    "Authorization": "Bearer xVQ5NLxSCAAj1h8KKREeITrgByhZCDgb", 
    "Host": "httpbin.org", 
    "User-Agent": "curl/8.8.0", 
    "X-Amzn-Trace-Id": "Root=1-667793c3-7ae759a84154bc2d37a53546", 
    "X-Authenticated-Scope": "email", 
    "X-Authenticated-Userid": "myconsumer", 
    "X-Consumer-Id": "0d4b6222-0b97-4233-9255-3eccd4f69a55", 
    "X-Consumer-Username": "myconsumer", 
    "X-Credential-Identifier": "XAAFpHgaavFTBdWNazfl5Vm0LfDEbNuw", 
    "X-Forwarded-Host": "kong.local.lan", 
    "X-Forwarded-Path": "/myroute", 
    "X-Forwarded-Prefix": "/myroute"
  }, 
  "json": null, 
  "method": "GET", 
  "origin": "xxx.xxx.xxx.xxx, xxx.xxx.xxx.xxx", 
  "url": "https://kong.local.lan/anything"
}
```

That's it, enjoy your oauth2 and protect everythings needed.

# Good practices

1. take care of token expiration time, adjust to a minimum possible to your needs
2. generate a single consumer per route or service, don't uses the same consumer to different purpose routes
3. refresh oauth2 provision_key always as possible
4. monitore your routes and provision_keys and disable unused ones
