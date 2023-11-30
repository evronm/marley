
# Introducing the Marley Framework for Picolisp

## Overview
Marley implements a highly efficient, declarative DSL for coupling database structures with front end structures.

The backend is written in picolisp, and the front end is plain javascript plus vanjs and umbrellajs.  No state is maintained on the client (except, of course, client state).

## Design Goals
- Sensible, override-able defaults.  
- Declararative style - Also overridable!
- Minimalism in code, documentation and testing.  This maximizes flexibility.
- Flexibility deserves its own bullet point.

## Prerequisites

- [picolisp](http://picolisp.com)

## Installation

1. Clone the Marley repository:
   ```bash
   git clone https://github.com/evronm/marley.git
   ```

2. Navigate to the Marley directory:
   ```bash
   cd marley
   ```

## Running a Simple Application

1. Start the Marley server:
   ```bash
   pil test/go.l +
   ```

   This launches the Marley server using the `server.l` script.

2. Access the application:
   - Open your web browser.
   - Navigate to `http://localhost:4200` (or the port specified in your configuration).

3. You should see the default Marley application running.

4. Play around in `testapp.l` and see if you can tailor it to your needs.

## Components
- **Server-Side Structure**:
  - `er_mods.l`: Enhances relation classes with additional capabilities.
  - `rentity.l`: A wrapper for database entities, integrating RESTful methods and utility functions.
  - `marley.l`: Contains core functions for processing requests, authentication, and authorization.
  - `server.l`: A basic web server, subject to future enhancements or complete replacement.
  - `util.l`: A collection of utility functions for common tasks.
- **Client-Side Components**:
  - `client.l`: Generates foundational client-side HTML.
  - `reggae.js`: Implements the client-side handling of Reggae messages.
  - `jamaica.js`: Additional JavaScript functionalities for the client interface.

## Testing Philosophy
The framework adopts a user story-driven testing approach, focusing on how the features fulfill actual user requirements and scenarios.  Testing is by no means comprehensive and needs a lot of work.

## Target Audience
Marley is particularly suitable for solo developers and small teams who value a straightforward and practical tool for their development processes.

## Naming Inspiration
It's a testament to the soundness of the framework that I am able to use such an orthagonal concept for my naming.  This was originally written in Ruby and made use of the Sinatra framework.  I thought the authors picked the wrong singer for a REST framework, so I chose Marley, and the rest kind of fell into place.  I may end up changing the client name to "Babylon" as it might be more appropriate.  As it is, Jamaica requests Reggae from Marley, and Marley complies.

## Current Status
Seems to me the server side is largely done, with the exception of the web server, which won't scale.  The front end needs work, which I'll do myself.  I used a purpose-built GPT to generate most of this document, and hope it will help me finish the test suite as well.  I've found it mostly useless for coding, but it generated all the css and I want to make use of it as much as possible.  So lots more docs are coming (I hope).
