const path = require('path');
const express = require("express");
const { postgraphile } = require("postgraphile");
const PgSimplifyInflectorPlugin = require("@graphile-contrib/pg-simplify-inflector");

const app = express();

app.use(
  postgraphile(process.env.DATABASE_URL || "postgres://localhost/todo?sslmode=disable", "app", {
    dynamicJson: true,
    appendPlugins: [PgSimplifyInflectorPlugin],
    enhanceGraphiql: true,
    graphiql: process.env.NODE_ENV !== "production",
    watchPg: process.env.NODE_ENV !== "production",
  })
);

if (process.env.NODE_ENV === 'production') {
  app.use(express.static(path.join(__dirname, 'client/build')));
  // Handle React routing, return all requests to React app
  app.get('*', function(req, res) {
    res.sendFile(path.join(__dirname, 'client/build', 'index.html'));
  });
}

app.listen(process.env.PORT || 44593);