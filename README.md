# My First Backend — Frank Sinatra

A small backend built with [Express](https://expressjs.com/) (a light web
framework for Node.js). All data is hard-coded — there is no database.

## Install

```bash
npm install
```

This downloads Express into `node_modules/` (which is git-ignored, so it is
never committed).

## Run

```bash
npm start
# or: node app.js
```

The server listens on `0.0.0.0:8080`, so it is reachable at
`http://web-XXXXXXXXX.docode.YYYY.qwasar.io`.

## Routes

| Method & path   | What it does                                                        |
| --------------- | ------------------------------------------------------------------- |
| `GET /`         | A random Frank Sinatra song (from a pool of 20+)                    |
| `GET /birth_date` | Frank Sinatra's birth date                                        |
| `GET /birth_city` | Frank Sinatra's birth city                                        |
| `GET /wives`    | All his wives: `wife1, wife2, wife3, wife4`                          |
| `GET /picture`  | Redirects to his picture on Wikipedia                               |
| `GET /public`   | Prints `Everybody can see this page`                                |
| `GET /protected`| HTTP Basic auth (`admin` / `admin`); otherwise `401 Not authorized` |

## Try it with curl

```bash
curl http://localhost:8080/
curl -i http://localhost:8080/protected
curl -i http://admin:admin@localhost:8080/protected
```
