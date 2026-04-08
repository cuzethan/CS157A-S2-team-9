# Welcome to SJSUMarketplace

So far, we were able to sucessfully immplement our homepage, and some of the features in the signup/login and listing pages

## Functional Requirements Completed

1. Allowing users to signup/login to the account
    * Added simple validation to signup page (making sure email ends with "@sjsu.edu", username and password properly have their requirements)
    * We implemented hashing passwords on signup, validated upon login

## Some features we want to add

1. Add session authentication to verify user login
2. Implement logging out
3. Let users post listings
4. Let users communicate with other users

and many more!

## Important sidenotes for professor or anyone testing.

* In src/main/java/Database.java, make sure you input your MySQL credentials for db, user, and password.
* The url to access the website locally should be http://localhost:8080/CS157A-Project/