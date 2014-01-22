#' update vertex normals of a triangular meshes or point clouds
#'
#' update vertex normals of a triangular meshes or point clouds
#' @param mesh triangular mesh of class 'mesh3d'
#' @param type select the method to compute per-vertex normals: 0=area weighted average of surrounding face normals; 1 = angle weighted vertex normals.
#' @param pointcloud add options for normal calculation of point clouds.
#'
#' @return mesh with updated/created normals
#'
#' @examples
#' data(humface)
#' humface$normals <- NULL # remove normals
#' humface <- vcgUpdateNormals(humface)
#' @export

vcgUpdateNormals <- function(mesh,type = 0, pointcloud=c(10,0))
    {
        if (is.matrix(mesh)) {
            tmp <- list()
            tmp$vb <- rbind(t(mesh),1)
            mesh <- tmp
        }
        vb <- mesh$vb[1:3,]
        if (!is.matrix(vb))
            stop("mesh has no vertices")
        it <- mesh$it-1
        if (! prod(is.integer(pointcloud)))
            pointcloud <- c(10,0)
        if (! type %in% c(0,1))
            stop("please set valid type")
        normals <- .Call("RupdateNormals", vb, it, type, pointcloud)
        mesh$normals <- rbind(normals,1)
        
        return(mesh)
    }
    
