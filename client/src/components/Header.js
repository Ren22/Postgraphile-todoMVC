import React from "react";
import TodoTextInput from "./TodoTextInput";
import gql from "graphql-tag";
import { Mutation } from "react-apollo";
import { GET_TODOS } from "./MainSection";

const CREATE_TODOS = gql`
  mutation CreateTodo($title: String) {
    createTodo(input: { todo: { title: $title } }) {
      todo {
        id
        title
        completed
      }
    }
  }
`;

class Header extends React.Component {
  updateTodos = (cache, { data }) => {
    const cacheData = cache.readQuery({
      query: GET_TODOS,
    });
    const todos =
      (cacheData.todos && cacheData.todos && cacheData.todos.nodes) || [];

    const newItem =
      (data &&
        data.createTodo &&
        data.createTodo.todo && [data.createTodo.todo]) ||
      [];

    cache.writeQuery({
      query: GET_TODOS,
      data: {
        ...cacheData,
        todos: {
          ...cacheData.todos,
          nodes: todos.concat(newItem),
        },
      },
    });
  };

  render() {
    return (
      <Mutation mutation={CREATE_TODOS} update={this.updateTodos}>
        {(createTodo, { loading, error, data }) => (
          <header className="header">
            <h1>todos</h1>
            <TodoTextInput
              newTodo
              onSave={text => createTodo({ variables: { title: text } })}
              placeholder="What needs to be done?"
            />
          </header>
        )}
      </Mutation>
    );
  }
}

export default Header;
