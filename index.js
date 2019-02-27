require("dotenv").config();
const path = require("path");
const express = require("express");
const cookieParser = require("cookie-parser");
const { postgraphile } = require("postgraphile");
const PgSimplifyInflectorPlugin = require("@graphile-contrib/pg-simplify-inflector");
const parseClaims = require("./auth");

const app = express();
app.use(cookieParser());

app.use(
  postgraphile(
    process.env.GRAPHILE_URL ||
      "postgres://todo_graphile:password@localhost/todo?sslmode=disable",
    "app",
    {
      dynamicJson: true,
      appendPlugins: [PgSimplifyInflectorPlugin],
      enhanceGraphiql: true,
      graphiql: process.env.NODE_ENV !== "production",
      watchPg: process.env.NODE_ENV !== "production",
      ignoreRBAC: false,
      pgSettings: async req => {
        try {
          const claimes = await parseClaims(req);

          return {
            role: "todo_user",
            "user.id": claimes.sub,
          };
        } catch (error) {
          console.error("failed to authenticate", error);
          return { role: "todo_anonymous" };
        }
      },
    }
  )
);

if (process.env.NODE_ENV === "production") {
  app.use(express.static(path.join(__dirname, "client/build")));
  // Handle React routing, return all requests to React app
  app.get("*", function(req, res) {
    res.sendFile(path.join(__dirname, "client/build", "index.html"));
  });
}

app.listen(process.env.PORT || 44593);
