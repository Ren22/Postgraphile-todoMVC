import React, { PropTypes, Component } from "react";
import gql from "graphql-tag";
import { Mutation } from "react-apollo";

const COMPLETE_ALL = gql`
  mutation {
    completeAll(input: {}) {
      todos {
        id
        title
        completed
      }
    }
  }
`;

export default class MainToggle extends Component {
  static propTypes = {
    todos: PropTypes.array.isRequired,
  };

  render() {
    const { todos } = this.props;
    const completedCount = todos.reduce(
      (count, todo) => (todo.completed ? count + 1 : count),
      0
    );

    if (todos.length <= 0) {
      return <span />;
    }

    return (
      <Mutation mutation={COMPLETE_ALL}>
        {completeAll => (
          <input
            className="toggle-all"
            type="checkbox"
            checked={completedCount === todos.length}
            onChange={completeAll}
          />
        )}
      </Mutation>
    );
  }
}
