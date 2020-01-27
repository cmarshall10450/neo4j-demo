LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/cmarshall10450/neo4j-demo/master/ratings.csv" AS row
MATCH (user:User { id: toInt(row.user_id) }), (movie:Movie { id: toInt(row.movie_id) })
MERGE (user)-[:RATED {rating: toInt(row.score)}]->(movie)
RETURN user, movie