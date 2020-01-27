// Create nodes for all movies
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/cmarshall10450/neo4j-demo/master/movies.csv" AS row
MERGE (movie:Movie { id: toInt(row.id) })
SET movie.title = row.title
RETURN movie