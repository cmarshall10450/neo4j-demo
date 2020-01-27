// Create contstraint and index on user id
CREATE CONSTRAINT ON (user:User) ASSERT user.id IS UNIQUE

// Create contstraint and index on movie id
CREATE CONSTRAINT ON (movie:Movie) ASSERT movie.id IS UNIQUE