#' Import common mesh file formats.
#' 
#' Import common mesh file formats and store the results in an object of
#' class "mesh3d" - momentarily only triangular meshes are supported.
#' 
#' 
#' @param file character: file to be read.
#' @param updateNormals logical: if TRUE and the imported file contais faces,
#' vertex normals will be (re)calculated. Otherwise, normals will be a matrix containing zeros.
#' @param readcolor if TRUE, vertex colors and texture (face and vertex) coordinates will be processed - if available, otherwise all vertices will be colored white.
#' @param clean if TRUE, duplicated and unreferenced vertices as well as duplicate faces are removed (be careful when importing point clouds).
#' @param silent logical, if TRUE no console output is issued.
#' @note currently only meshes with either color or texture can be processed. If both are present, the function will mark the mesh as non-readable.
#' @return Object of class "mesh3d"
#' 
#' with:
#' \item{vb }{4 x n matrix containing n vertices as homolougous coordinates}
#' \item{it }{3 x m matrix containing vertex indices forming triangular faces}
#' \item{normals }{4 x n matrix containing vertex normals (homologous coordinates)}
#'
#' in case the imported files contains face or vertex quality, these will be stored as vectors named $quality (for vertex quality) and $facequality
#'
#'
#' if the imported file contains vertex colors and readcolor = TRUE, these will be saved in $material$color according to "mesh3d" specifications.
#' @author Stefan Schlager
#' @seealso \code{\link{vcgSmooth}}
#' @examples
#' data(humface)
#' vcgPlyWrite(humface)
#' readit <- vcgImport("humface.ply")
#' @keywords ~kwd1 ~kwd2
#' @export 

vcgImport <- function(file, updateNormals = TRUE, readcolor=FALSE, clean = TRUE,silent=FALSE) {
     
    ncfile <- nchar(file)
    ext <- substr(file,ncfile-2,ncfile)
    file <- path.expand(file)
    x <- file
    if (length(x) != 1)
        stop("only one file at a time please")
    if (! file.exists(x))
        stop(paste0("file ", file," does not exist"))
    ## get file and folder names and cd to target directory
    wdold <- getwd()
    folder <- dirname(file)
    file <- basename(file)
    setwd(folder)
    
    updateNormals <- as.logical(updateNormals)
    readcolor <- as.logical(readcolor)
    clean <- as.logical(clean)


    tmp <- try(.Call("RallRead", file, updateNormals, readcolor, clean, silent))
    
    ## go back to current wd
    setwd(wdold)
    if (inherits(tmp,"try-error"))
        stop("mesh is not readable")
    out <- list()
    class(out) <- "mesh3d"
    
    out$vb <- rbind(matrix(tmp$vb,3,length(tmp$vb)/3),1)
    if (length(tmp$it))
        out$it <- matrix(tmp$it,3,(length(tmp$it)/3))+1
    if (length(tmp$normals))
        out$normals <- rbind(matrix(tmp$normals,3,length(tmp$normals)/3),1)
    if (readcolor) {
        out$material <- list()
            if (length(tmp$colors)) {
                colvec <- matrix(tmp$colors,3,(length(tmp$colors)/3))
                colvec <- rgb(colvec[1,],colvec[2,],colvec[3,],maxColorValue=255)
                colfun <- function(x)
                    {
                        x <- colvec[x]
                        return(x)
                    }
                out$material$color <- matrix(colfun(out$it),dim(out$it))
            }
            if (length(tmp$texfile)) {
                if (length(tmp$texfile) > 1)
                    message("only single texture files supported, only first one stored")
                tmp$texfile <- tmp$texfile[1]
                setwd(folder)
                imghandle <- convertTexture(tmp$texfile,wdold)
                setwd(wdold)
                
                out$material$texture <- imghandle$texfile
                if(!imghandle$exist)
                    message("autoconversion of texture image failed: please convert texture images to png format manually")
                out$texcoords <- matrix(tmp$texcoord,2,length(tmp$texcoord)/2)
                if (ncol(out$texcoords) > ncol(out$vb))
                    out$texcoords <- out$texcoords[,1:ncol(out$vb)]
            }
    }
    if (length(tmp$quality))
        out$quality <- tmp$quality
    if (length(tmp$facequality))
        out$facequality <- tmp$facequality
    return(out)
}

#' @importFrom readbitmap read.bitmap
#' @importFrom png writePNG
convertTexture <- function(texfile,folder="./") {
      
    hack <- unlist(strsplit(texfile,split="[.]"))
    ext <- hack[length(hack)]
    base <- paste(hack[-length(hack)],collapse = ".")
    if (!file.exists(texfile))
        return(list(exist=FALSE,texfile=paste0(base,".png")))
    
    exist <- TRUE
    if (! ext %in% c("png","PNG")) {
        img <- read.bitmap(texfile)
        chk <- try(writePNG(img,paste0(folder,"/",base,".png")))
        if (inherits(chk,"try-error") || inherits(img,"try-error"))
            exist <- FALSE
    } else {
        chk <- try(file.copy(texfile,folder))
        if (inherits(chk,"try-error"))
            exist <- FALSE
    }
    return(list(exist=exist,texfile=paste0(base,".png")))
}
        
