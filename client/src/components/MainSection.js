import React, { Component } from "react";
import TodoItem from "./TodoItem";
import Footer from "./Footer";
import gql from "graphql-tag";
import { Query } from "react-apollo";
import MainToggle from "./MainToggle";

export const GET_TODOS = gql`
  {
    todos(orderBy: CREATED_AT_ASC) {
      nodes {
        id
        title
        completed
      }
    }
  }
`;

const TODO_FILTERS = {
  SHOW_ALL: () => true,
  SHOW_ACTIVE: todo => !todo.completed,
  SHOW_COMPLETED: todo => todo.completed,
};

export default class MainSection extends Component {
  state = { filter: "SHOW_ALL" };

  handleShow = filter => {
    this.setState({ filter });
  };

  render() {
    const { filter } = this.state;

    return (
      <Query query={GET_TODOS}>
        {({ loading, error, data }) => {
          const todos = (data.todos && data.todos.nodes) || [];
          const filteredTodos = todos.filter(TODO_FILTERS[filter]);

          return (
            <section className="main">
              <MainToggle todos={todos} />
              <ul className="todo-list">
                {filteredTodos.map(todo => (
                  <TodoItem key={todo.id} todo={todo} />
                ))}
              </ul>
              <Footer todos={todos} filter={filter} onShow={this.handleShow} />
            </section>
          );
        }}
      </Query>
    );
  }
}
