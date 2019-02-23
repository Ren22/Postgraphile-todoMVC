import React, { PropTypes, Component } from "react";
import classnames from "classnames";
import gql from "graphql-tag";
import { Mutation } from "react-apollo";
import { GET_TODOS } from "./MainSection";

const CLEAR_COMPLETED = gql`
  mutation {
    clearCompleted(input: {}) {
      todos {
        id
      }
    }
  }
`;

const FILTER_TITLES = {
  SHOW_ALL: "All",
  SHOW_ACTIVE: "Active",
  SHOW_COMPLETED: "Completed",
};

export default class Footer extends Component {
  static propTypes = {
    filter: PropTypes.string.isRequired,
    onShow: PropTypes.func.isRequired,
    todos: PropTypes.array.isRequired,
  };

  renderTodoCount() {
    const activeCount = this.activeCount();

    const itemWord = activeCount === 1 ? "item" : "items";

    return (
      <span className="todo-count">
        <strong>{activeCount || "No"}</strong>
        {itemWord} left
      </span>
    );
  }

  renderFilterLink(filter) {
    const title = FILTER_TITLES[filter];
    const { filter: selectedFilter, onShow } = this.props;

    return (
      <a
        className={classnames({ selected: filter === selectedFilter })}
        style={{ cursor: "pointer" }}
        onClick={() => onShow(filter)}
      >
        {title}
      </a>
    );
  }

  renderFilterList() {
    return ["SHOW_ALL", "SHOW_ACTIVE", "SHOW_COMPLETED"].map(filter => (
      <li key={filter}>{this.renderFilterLink(filter)}</li>
    ));
  }

  updateAfterClearAll = (cache, { data }) => {
    const cacheData = cache.readQuery({
      query: GET_TODOS,
    });
    const todos =
      (cacheData.todos && cacheData.todos && cacheData.todos.nodes) || [];

    const deletedIds = data.clearCompleted.todos.map(t => t.id);

    cache.writeQuery({
      query: GET_TODOS,
      data: {
        ...cacheData,
        todos: {
          ...cacheData.todos,
          nodes: todos.filter(t => !deletedIds.includes(t.id)),
        },
      },
    });
  };

  completedCount() {
    const { todos } = this.props;
    return todos.reduce((count, todo) => {
      return todo.completed ? count + 1 : count;
    }, 0);
  }

  activeCount() {
    const { todos } = this.props;
    return todos.length - this.completedCount();
  }

  render() {
    const { todos } = this.props;

    if (todos.length <= 0) {
      return <span />;
    }

    return (
      <Mutation mutation={CLEAR_COMPLETED} update={this.updateAfterClearAll}>
        {clearCompleted => (
          <footer className="footer">
            {this.renderTodoCount()}

            <ul className="filters">{this.renderFilterList()}</ul>

            {this.completedCount() > 0 && (
              <button className="clear-completed" onClick={clearCompleted}>
                Clear completed
              </button>
            )}
          </footer>
        )}
      </Mutation>
    );
  }
}
