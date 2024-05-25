// Create contstraint and index on user id
CREATE CONSTRAINT ON (user:User) ASSERT user.id IS UNIQUE

// Create contstraint and index on movie id
CREATE CONSTRAINT ON (movie:Movie) ASSERT movie.id IS UNIQUE

// ------------------------------------------------------------------------------------------

// Create nodes for all users
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/cmarshall10450/neo4j-demo/master/neo4j-demo/users.csv" AS row
MERGE (user:User { id: toInt(row.id) })
SET user.name = row.first_name + " " + row.last_name
RETURN user

// ------------------------------------------------------------------------------------------

// Create nodes for all movies
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/cmarshall10450/neo4j-demo/master/neo4j-demo/movies.csv" AS row
MERGE (movie:Movie { id: toInt(row.id) })
SET movie.title = row.title
RETURN movie

// Display all users and movies with no relationships
MATCH (user:User), (movie:Movie)
RETURN user, movie

// ------------------------------------------------------------------------------------------

// Create relationships between users and movies
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/cmarshall10450/neo4j-demo/master/neo4j-demo/ratings.csv" AS row
MATCH (user:User { id: toInt(row.user_id) }), (movie:Movie { id: toInt(row.movie_id) })
MERGE (user)-[:RATED {rating: toInt(row.score)}]->(movie)
RETURN user, movie

// ------------------------------------------------------------------------------------------

// Calculate similarity for all users
MATCH (user1:User)-[x:RATED]->(movie:Movie)<-[y:RATED]-(user2:User)
WITH  SUM(x.rating * y.rating) AS xyDotProduct,
      SQRT(REDUCE(xDot = 0.0, a IN COLLECT(x.rating) | xDot + a^2)) AS xLength,
      SQRT(REDUCE(yDot = 0.0, b IN COLLECT(y.rating) | yDot + b^2)) AS yLength,
      user1,
      user2
MERGE (user1)-[s:SIMILARITY]-(user2)
SET   s.similarity = xyDotProduct / (xLength * yLength)

// ------------------------------------------------------------------------------------------

// Add new user and calculate similarity to other users
CREATE (me:User { id: 16 })
SET    me.name = "Chris Marshall"

LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/cmarshall10450/neo4j-demo/master/neo4j-demo/my_ratings.csv" as row
MATCH (me:User { name: "Chris Marshall" }), (movie:Movie { id: toInt(row.movie_id) })
MERGE (me)-[:RATED { rating: toInt(row.score) }]->(movie)

MATCH (me:User { name: "Chris Marshall" })-[x:RATED]->(movie:Movie),
      (other:User)-[y:RATED]->(movie)
WITH  SUM(x.rating * y.rating) AS xyDotProduct,
      SQRT(REDUCE(xDot = 0.0, a IN COLLECT(x.rating) | xDot + a^2)) AS xLength,
      SQRT(REDUCE(yDot = 0.0, b IN COLLECT(y.rating) | yDot + b^2)) AS yLength,
      me,
      other
MERGE (me)-[s:SIMILARITY]-(other)
SET   s.similarity = xyDotProduct / (xLength * yLength)

// ------------------------------------------------------------------------------------------------

// View similarity from me to all other users
MATCH    (me:User { name: "Chris Marshall" })-[s:SIMILARITY]-(other:User)
WITH     other, s.similarity AS sim
ORDER BY sim DESC
LIMIT    5
RETURN   other.name AS Neighbor, sim AS Similarity

// Recommend movies I haven't rated yet based on the ratings from other users
MATCH    (other:User)-[r:RATED]->(movie:Movie), (other)-[s:SIMILARITY]-(me:User {name:'Chris Marshall'})
WHERE    NOT((me)-[:RATED]->(movie))
WITH     movie, s.similarity AS similarity, r.rating AS rating
ORDER BY movie.title, similarity DESC
WITH     movie.title AS movie, COLLECT(rating)[0..3] AS ratings
WITH     movie, REDUCE(s = 0, i IN ratings | s + i) * 1.0 / LENGTH(ratings) AS reco
ORDER BY reco DESC
LIMIT    10
RETURN   movie AS Movie, reco AS Recommendation
