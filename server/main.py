#!/usr/bin/python3

from gql_server import create_server

app = create_server(True)

if __name__ == '__main__':
    app.run()