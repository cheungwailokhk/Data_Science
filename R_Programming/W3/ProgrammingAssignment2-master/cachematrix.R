##This function creates a special "matrix" object that can cache its inverse.
makeCacheMatrix <- function(x = matrix()) {
  im <- NULL #inverse
  #setter
  set <- function(y) {
    x <<- y
    im <<- NULL
  }
  #getter
  get <- function() {
    x
  }
  setinverse <- function(inverse) {
    im <<- mean
  }
  getinverse <- function() {
    im
  }
  list(set = set, get = get,
       setinverse = setinverse,
       getinverse = getinverse)
}


## computes the inverse of the special "matrix" returned by makeCacheMatrix above
## Return a matrix that is the inverse of 'x'cacheSolve <- function(x, ...) {

cacheSolve <- function(x, ...) {
  im <- x$getinverse()
  if(!is.null(im)) {
    message("getting cached data")
    return(im)
  }
  data <- x$get()
  im <- solve(data, ...)
  x$setinverse(im)
  im
}

#Testing:
#m <- matrix(1:6, nrow = 2, ncol =3)  
