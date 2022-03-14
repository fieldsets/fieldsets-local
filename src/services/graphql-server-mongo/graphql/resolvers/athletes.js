const Athlete = require('../../models/Athlete')
const { ApolloError } = require('apollo-server-errors')
const bcrypt = require('bcryptjs')
const jwt = require('jsonwebtoken')
require('dotenv').config()

const AUTH_STRING = process.env.AUTH_STRING

export default {
  Mutation: {
    athleteRegistration: async (_, { registerAthlete: {username, email, password} }) => {
      
      //Check if user exists
      let oldUser = await Athlete.findOne({ email });
     
      //Throw error if user exists
      if (oldUser) {
        throw new ApolloError('A user is already registed with this email: ' + email, 'USER_ALREADY_EXISTS' )
      }

      //Encrypt password
      let encryptedPassword = await bcrypt.hashSync(password, 10)
      
      //Build mongoose model
      const newAthlete = new Athlete({
        username: username,
        email: email.toLowerCase(),
        password: encryptedPassword,
      })

      console.log('new athlete: ', newAthlete)

      //Create JWT
      const token = jwt.sign(
        { user_id: newAthlete._id, email },
        AUTH_STRING,
        {
          expiresIn: "2h"
        }
      )

      newAthlete.token = token;

      //Save user to mongoDB
      const savedUser = await newAthlete.save();
        
      return savedUser
    },
    async loginAthlete(_, { athleteLogin: { email, password } }) {
      //See if user exists with email
      let user = await Athlete.findOne({ email });

      //Check is password matches encrypted password
      if (user && await (bcrypt.compare(password, user.password))) {
        //Create a NEW token
        const token = jwt.sign(
          { user_id: newAthlete._id, email },
          AUTH_STRING,
          {
            expiresIn: "2h"
          }
        )
        //Attach token to user found above
        user.token = token;

        return {
          id: user.id,
          ...user._doc
        }
      } else {
        //If no user throw error
        throw new ApolloError('Incorrect password', 'INCORRECT_PASSWORD')
      }      
    }
  },
  Query: {
    athlete: (_, {ID}) => Athlete.findById(ID)
  }
}