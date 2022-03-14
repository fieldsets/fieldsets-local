const User = require('../../models/User');
const { ApolloError } = require('apollo-server-errors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken')
require('dotenv').config();

const AUTH_STRING = process.env.AUTH_STRING

module.exports = {
  Mutation: {
    async registerUser(_, { registerInput: { username, email, password } }) {
      //Check if user already exists
      const oldUser = await User.findOne({email})

      //Throw error if user exists
      if (oldUser) {
        throw new ApolloError('A user is already registered with this email ' + email, 'USER_ALREADY_EXISTS')
      }

      //Encrypt password
      var encryptedPassword = await bcrypt.hash(password, 10)

      //Build mongoose model
      const newUser = new User({
        username: username,
        email: email.toLowerCase(),
        password: encryptedPassword
      });

      //Create JWT token and attach to user
      const token = jwt.sign(
        { user_id: newUser._id, email },
        AUTH_STRING,
        {
          expiresIn: "2h"
        }
      );

      newUser.token = token;

      //Save user in mongoDB

      const res = await newUser.save()

      return {
        id: res.id,
        ...res._doc
      }
    },
    async loginUser(_, { loginInput: { email, password } }) {
      //See if user already exists with email
      const user = await User.findOne({ email })
      
      //Check if entered password = encrypted password
      if (user && (await bcrypt.compare(password, user.password))) {
         //Create new token
        const token = jwt.sign(
          { user_id: user._id, email },
          AUTH_STRING,
          {
            expiresIn: "2h"
          }
        )
        //Attach token to User model
        user.token = token
        
        return {
          id: user.id,
          ...user._doc
        }

      } else {
        //If no user exists return error
        throw new ApolloError('Incorrect Password', 'INCORRECT_PASSWORD')
      }
    }
  },
  Query: {
    user: (_,{ID}) => User.findById(ID)
  }
}