import React, { Component, PropTypes } from "react";
import classnames from "classnames";
import TodoTextInput from "./TodoTextInput";
import gql from "graphql-tag";
import { Mutation } from "react-apollo";
import { GET_TODOS } from "./MainSection";

const DELETE_TODO = gql`
  mutation DeleteTodo($id: Int!) {
    deleteTodoById(input: { id: $id }) {
      todo {
        id
      }
    }
  }
`;

const UPDATE_TODO = gql`
  mutation UpdateTodo($id: Int!, $title: String!) {
    updateTodoById(input: { patch: { title: $title }, id: $id }) {
      todo {
        id
        title
        completed
      }
    }
  }
`;

const COMPLETE_TODO = gql`
  mutation UpdateTodo($id: Int!, $completed: Boolean!) {
    updateTodoById(input: { patch: { completed: $completed }, id: $id }) {
      todo {
        id
        title
        completed
      }
    }
  }
`;

export default class TodoItem extends Component {
  static propTypes = {
    todo: PropTypes.object.isRequired,
  };

  state = {
    editing: false,
  };

  handleDoubleClick = () => {
    this.setState({ editing: true });
  };

  updateForDelete = (cache, { data }) => {
    const cacheData = cache.readQuery({
      query: GET_TODOS,
    });
    const todos =
      (cacheData.todos && cacheData.todos && cacheData.todos.nodes) || [];

    const deletedId = data.deleteTodoById.todo.id;

    cache.writeQuery({
      query: GET_TODOS,
      data: {
        ...cacheData,
        todos: {
          ...cacheData.todos,
          nodes: todos.filter(t => t.id !== deletedId),
        },
      },
    });
  };

  render() {
    const { todo } = this.props;

    let element;
    if (this.state.editing) {
      element = (
        <Mutation mutation={DELETE_TODO} update={this.updateForDelete}>
          {deleteTodo => (
            <Mutation mutation={UPDATE_TODO}>
              {updateTodo => (
                <TodoTextInput
                  text={todo.title}
                  editing={this.state.editing}
                  onSave={text => {
                    if (text.length === 0) {
                      deleteTodo({ variables: { id: todo.id } });
                    } else {
                      updateTodo({ variables: { id: todo.id, title: text } });
                    }
                    this.setState({ editing: false });
                  }}
                />
              )}
            </Mutation>
          )}
        </Mutation>
      );
    } else {
      element = (
        <Mutation mutation={COMPLETE_TODO}>
          {complete => (
            <div className="view">
              <input
                className="toggle"
                type="checkbox"
                checked={todo.completed}
                onChange={() =>
                  complete({
                    variables: { id: todo.id, completed: !todo.completed },
                  })
                }
              />
              <label onDoubleClick={this.handleDoubleClick}>{todo.title}</label>
              <button className="destroy" onClick={() => {}} />
            </div>
          )}
        </Mutation>
      );
    }

    return (
      <li
        className={classnames({
          completed: todo.completed,
          editing: this.state.editing,
        })}
      >
        {element}
      </li>
    );
  }
}
