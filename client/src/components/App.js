import React, { Component } from "react";
import Header from "./Header";
import MainSection from "./MainSection";
import "unfetch/polyfill";
import ApolloClient from "apollo-boost";
import { ApolloProvider } from "react-apollo";
import { createHttpLink } from "apollo-link-http";

const client = new ApolloClient();
client.link = createHttpLink({ uri: "http://localhost:3000/graphql" });

class App extends Component {
  completeAll = () => {
    const areAllMarked = this.state.todos.every(todo => todo.completed);
    const todos = this.state.todos.map(todo => {
      return { ...todo, completed: !areAllMarked };
    });
    this.setState({ todos });
  };

  clearCompleted = () => {
    const todos = this.state.todos.filter(todo => todo.completed === false);
    this.setState({ todos });
  };

  actions = {
    completeAll: this.completeAll,
    clearCompleted: this.clearCompleted,
  };

  render() {
    return (
      <ApolloProvider client={client}>
        <div>
          <Header />
          <MainSection actions={this.actions} />
        </div>
      </ApolloProvider>
    );
  }
}

export default App;
