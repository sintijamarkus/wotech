// My First Backend - Frank Sinatra
// A small Express backend. All data is hard-coded (no database).

const express = require('express');

const app = express();

// Do not advertise the framework.
app.disable('x-powered-by');

// Hard-coded data about Frank Sinatra.
// Sources: Wikipedia (https://en.wikipedia.org/wiki/Frank_Sinatra)
const SONGS = [
  'New York, New York',
  'My Way',
  'Fly Me to the Moon',
  'Strangers in the Night',
  'Come Fly with Me',
  'The Way You Look Tonight',
  "I've Got You Under My Skin",
  "That's Life",
  "Somethin' Stupid",
  'Luck Be a Lady',
  'Witchcraft',
  'Chicago',
  'Summer Wind',
  'It Was a Very Good Year',
  'Young at Heart',
  'All the Way',
  'Night and Day',
  'Love and Marriage',
  'The Lady Is a Tramp',
  "Nice 'n' Easy",
  'In the Wee Small Hours of the Morning',
  'One for My Baby',
  'Autumn in New York',
  "I've Got the World on a String",
];

const BIRTH_DATE = 'December 12, 1915';
const BIRTH_CITY = 'Hoboken, New Jersey';
const WIVES = ['Nancy Barbato', 'Ava Gardner', 'Mia Farrow', 'Barbara Marx'];
const PICTURE_URL =
  'https://en.wikipedia.org/wiki/Frank_Sinatra#/media/File:Frank_Sinatra2,_Pal_Joey.jpg';

// Security headers, matching the expected responses.
app.use((req, res, next) => {
  res.set('X-XSS-Protection', '1; mode=block');
  res.set('X-Content-Type-Options', 'nosniff');
  res.set('X-Frame-Options', 'SAMEORIGIN');
  res.type('html');
  next();
});

// Part I & II: a random Frank Sinatra song.
app.get('/', (req, res) => {
  const song = SONGS[Math.floor(Math.random() * SONGS.length)];
  res.send(song);
});

// Part II: birth date.
app.get('/birth_date', (req, res) => {
  res.send(BIRTH_DATE);
});

// Part II: birth city.
app.get('/birth_city', (req, res) => {
  res.send(BIRTH_CITY);
});

// Part II: wives, formatted "wife1, wife2, wife3, wife4".
app.get('/wives', (req, res) => {
  res.send(WIVES.join(', '));
});

// Part II: redirect to Frank Sinatra's picture.
app.get('/picture', (req, res) => {
  res.redirect(PICTURE_URL);
});

// Part III: public page.
app.get('/public', (req, res) => {
  res.send('Everybody can see this page');
});

// Part III: protected page behind HTTP Basic authentication (admin/admin).
app.get('/protected', (req, res) => {
  const header = req.headers.authorization || '';
  const [scheme, encoded] = header.split(' ');

  if (scheme === 'Basic' && encoded) {
    const [user, pass] = Buffer.from(encoded, 'base64').toString().split(':');
    if (user === 'admin' && pass === 'admin') {
      return res.send('Welcome, authenticated client');
    }
  }

  res.set('WWW-Authenticate', 'Basic realm="Restricted Area"');
  res.status(401).send('Not authorized');
});

const PORT = process.env.PORT || 8080;
const HOST = '0.0.0.0';

app.listen(PORT, HOST, () => {
  console.log(`Server listening on http://${HOST}:${PORT}`);
});

module.exports = app;
