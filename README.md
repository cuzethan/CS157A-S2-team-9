# Welcome to SJSUMarketplace

This project is like a Facebook marketplace, but for students/faculty at San Jose State!

## Important sidenotes for professor or anyone testing.

* The reason We kept Database.java as a shared connection helper to avoid duplicating JDBC credentials and connection setup across multiple JSP files. This reduces repetition, makes updates easier, and lowers the risk of inconsistent or incorrect DB settings.
Database.java isn't a serverlet, only a utility, so I hope you'll allow this exception.
* In src/main/java/com/cs157a/Database.java, make sure you input your MySQL credentials for db, user, and password.
* The url to access the website locally should be http://localhost:8080/CS157A-Project/
* In the init_db.sql script, there's is a test user with admins already generated
ex. (Username: "testing1", Password: "password")
* For testing purposes, run initdb.sql to get the tables properly configured, then set the propdata.sql
