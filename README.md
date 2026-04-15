# Welcome to SJSUMarketplace

So far, we were able to sucessfully immplement our homepage, and some of the features in the signup/login and listing pages

## Functional Requirements Completed

1. Allow users to sign up with validation (@sjsu.edu, username/password rules).
2. Allow users to log in with hashed password verification.
3. Allow users to log out by invalidating session and returning to home.
4. Allow authenticated users to create listings (title, price, description, meetup location, optional image).
5. Allow users to browse and filter listings by keyword, location, price range, and sort order.
6. Allowed administrators to see additional header for their personal dashboard (acutal functionality still in progress)
    - Non-admins will not be able to access it.

## Some features we want to add

1. Add session authentication to verify user login
2. Implement logging out
3. Let users post listings
4. Let users communicate with other users

and many more!

## Important sidenotes for professor or anyone testing.

* The reason We kept Database.java as a shared connection helper to avoid duplicating JDBC credentials and connection setup across multiple JSP files. This reduces repetition, makes updates easier, and lowers the risk of inconsistent or incorrect DB settings.
Database.java isn't a serverlet, only a utility, so I hope you'll allow this exception.
* In src/main/java/com/cs157a/Database.java, make sure you input your MySQL credentials for db, user, and password.
* The url to access the website locally should be http://localhost:8080/CS157A-Project/
* In the init_db.sql script, there's is a test user with admin already generated (Username: "testing", Password: "Testing123!")
* For now, run initdb.sql and then the alter_picture.sql. In the finalized version we will use a completed single sql script.