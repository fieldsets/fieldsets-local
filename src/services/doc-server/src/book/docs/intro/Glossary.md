
# Glossary
This is a glossary of useful terms that can serve as a reference while following along with the lectures

Script - replaces the idea of the public key address

Redeemer - replaces digital signature. Tells script if unspent transaction can be consumed

Datum - A piece of data that can be attached to a transaction

UTXO - unspent transaction output. The model used in Bitcoin. Every transaction 

eUTXO - extended unspent transaction

validator - a function that takes 3 inputs of script, redeemer and datum as input and either passes/validates a transaction or throws an error/fails

## Plutus Core

BuiltInData - built in Haskell data type.

Data - custom plutus data type

Unit - the Haskell equivalent of the void data type. Denoted in Haskell with `()`