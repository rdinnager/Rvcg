% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/vcgSubdivide.r
\name{vcgSubdivide}
\alias{vcgSubdivide}
\title{subdivide the triangles of a mesh}
\usage{
vcgSubdivide(x, threshold = NULL, type = c("Butterfly", "Loop"),
  looptype = c("loop", "regularity", "continuity"), iterations = 3,
  silent = FALSE)
}
\arguments{
\item{x}{triangular mesh of class "mesh3d"}

\item{threshold}{minimum edge length to subdivide}

\item{type}{character: algorithm used. Options are Butterfly and Loop (see notes)}

\item{looptype}{character: method for type = loop options are "loop","regularity","continuity" (see notes)}

\item{iterations}{integer: number of iterations}

\item{silent}{logical: suppress output.}
}
\value{
returns subdivided mesh
}
\description{
subdivide the triangles of a mesh
}
\note{
The different algorithms are (from meshlab description):
\itemize{
\item{\bold{Butterfly Subdivision:} Apply Butterfly Subdivision Surface algorithm. It is an interpolated method, defined on arbitrary triangular meshes. The scheme is known to be C1 but not C2 on regular meshes}
\item{\bold{Loop Subdivision:} Apply Loop's Subdivision Surface algorithm. It is an approximant subdivision method and it works for every triangle and has rules for extraordinary vertices. Options are "loop" a simple subdivision, "regularity" to enhance the meshe's regularity and "continuity" to enhance the mesh's continuity.}
}
}
\examples{
data(humface)
subdivide <- vcgSubdivide(humface,type="Loop",looptype="regularity")

}
