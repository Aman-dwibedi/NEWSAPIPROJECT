# GNews API Wrapper

This project is a simple API wrapper for the GNews API, which allows you to search for news articles using the GNews API service.

## Introduction

The GNews API Wrapper is a web server that acts as an intermediary between your application and the GNews API. It provides a more straightforward interface for accessing the GNews API, abstracting away the details of making HTTP requests and handling responses.

## Getting Started

### Prerequisites

To use the GNews API Wrapper, you need to have the following prerequisites installed on your machine:

- Haskell GHC (Glasgow Haskell Compiler)
- Cabal (Haskell's build system and package manager)

### Installation

To run the GNews API Wrapper, follow these steps:

1. Clone this GitHub repository to your local machine.
2. Navigate to the project directory.
3. Use Cabal to build the project:


### Building the project

cabal build

### Starting the server

cabal run

### API Endpoint

The GNews API Wrapper provides a single endpoint to search for news articles. To use the API, send a GET request to the following URL:

http://localhost:8081/search?q=QUERY&apikey=APIKEY

Replace QUERY with your search query and APIKEY with your GNews API key.


