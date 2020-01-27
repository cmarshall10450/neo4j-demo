// Create nodes for all users
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/cmarshall10450/neo4j-demo/master/users.csv" AS row
MERGE (user:User { id: toInt(row.id) })
SET user.name = row.first_name + " " + row.last_name
RETURN user