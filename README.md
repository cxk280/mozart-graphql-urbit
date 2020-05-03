# Mozart, a GraphQL Server for Hoon

This project is a GraphQL Server established according to the official spec (see [here](https://github.com/graphql/graphql-spec) and [here](https://spec.graphql.org/June2018/)). It is client-agnostic. So far, we've been testing it with [Insomnia](https://insomnia.rest/), which offers a handy option to send a GraphQL-formatted request, but technically any HTTP POST request conforming to the spec should work.

The options for using Urbit as a database are currently limited, so for the time being Mozart simply relies upon a JSON file in `/home/lib/graphql/` as its data source. Current functionality is limited to queries. Future features include the following principal elements of a complete GraphQL Server:

*  Handle nested query layers with more than one item, like the following:

  ```
  {
    getBooks {
      author
      title
    }
  }
  ```

*  Mutations with and without inputs
*  Rigorous validation (basic validation is already included)
*  Extensive error handling for malformed queries and mutations
*  Introspection
*  User auth
*  A test suite

To test, use Insomnia or a similar tool to send a GraphQL request of the following form:

```
{
  getBooks {
    author
  }
}
```

or

```
{
  getBooks {
    title
  }
}
```

You should receive the proper data in response. For now, this response is a simple string indicating the data payload returned. Eventually, we intend to have detailed responses including relevant metadata about the request.

Contributors: this repo follows the [Conventional Commit](https://www.conventionalcommits.org/) spec. You may wish to download the [VSCode Conventional Commit extension](https://marketplace.visualstudio.com/items?itemName=vivaxy.vscode-conventional-commits) if you use VSCode as your text editor.