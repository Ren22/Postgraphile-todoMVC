# Fullstack ToDo using [PostGraphile](https://www.graphile.org/postgraphile/)

## Usage

### ENV

Make sure to rename both `.env.example` and `client/.env.example` to `.env` and fill out the Auth0 values with your account info.

### dbmate

You'll need to [install dbmate](https://github.com/amacneil/dbmate#installation). To create the db or run any new migrations, run `dbmate up`.

Make sure to also create a `todo_graphile` login role, with a password matching the one in your `.env` file.

```bash
psql -c "CREATE ROLE todo_graphile LOGIN PASSWORD 'password';"
```

### Starting

To run both the client and the server at the same time in dev mode, run `yarn dev`.
