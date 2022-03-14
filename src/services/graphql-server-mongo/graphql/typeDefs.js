const { gql } = require('apollo-server');

module.exports = gql`
    type Athlete {
      username: String
      first_name: String
      last_name: String
      email: String
      password: String
      token: String
      cards: [Card]
    }

    type User {
      username: String
      email: String
      password: String
      token: String
    }

    input RegisterInput {
      username: String
      email: String
      password: String
      confirmPassword: String
    }

    input LoginInput {
      email: String
      password: String
    }

    type Buyer {
      id: Int!
      username: String
      first_name: String
      last_name: String
      email: String
      password: String
      token: String
      cards: [Card]!
    }

    type Card {
      id: Int!
      title: String!
      cover_image_url: String!
      average_rating: Float!
      athlete: Athlete!
    }

    input RegisterAthlete {
      username: String
      email: String
      password: String
      confirmPassword: String
    }
    
    input BuyerRegistration {
      username: String
      email: String
      password: String
    }

    input AthleteLogin {
      email: String
      password: String
    }
    
    input BuyerLogin {
      username: String
      password: String
    }

    type Query {
      athlete(id: ID!): Athlete
      user(id: ID!): User
    }

    type Mutation {
      registerUser(registerInput: RegisterInput): User
      loginUser(loginInput: LoginInput): User

      addCard(title: String!, cover_image_url: String!, average_rating: Float!, athleteId: Int!): Card!
      athleteRegistration(registerAthlete: RegisterAthlete): Athlete!
      loginAthlete(athleteLogin: AthleteLogin): Athlete!
    }
  `;